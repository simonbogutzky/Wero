//
//  LoyaltyEngine.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation
import FoundationModels
import SwiftData

@Observable
final class LoyaltyEngine {
    // MARK: - Properties

    var isProcessing: Bool = false

    // MARK: - Methods

    func processTransaction(
        amount: Double,
        paymentType: PaymentType,
        loyaltyProfile: LoyaltyProfile,
        modelContext: ModelContext
    ) {
        loyaltyProfile.updateStreak()

        let basePoints = calculateBasePoints(for: amount, paymentType: paymentType)
        loyaltyProfile.addPoints(basePoints)

        let cashback = amount * loyaltyProfile.currentLevel.cashbackRate
        loyaltyProfile.addCashback(cashback)

        try? modelContext.save()
    }

    func checkAndUnlockAchievements(
        userId: String,
        loyaltyProfile: LoyaltyProfile,
        modelContext: ModelContext
    ) {
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.userId == userId }
        )

        guard let transactions = try? modelContext.fetch(descriptor) else { return }

        let achievementTypes = AchievementType.allCases
        for achievementType in achievementTypes {
            checkAchievement(
                type: achievementType,
                userId: userId,
                transactions: transactions,
                loyaltyProfile: loyaltyProfile,
                modelContext: modelContext
            )
        }
    }

    func generatePersonalizedRewards(
        userId: String,
        modelContext: ModelContext
    ) async -> [Reward] {
        isProcessing = true
        defer { isProcessing = false }

        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        guard let transactions = try? modelContext.fetch(descriptor) else { return [] }

        let insights = analyzeUserBehavior(transactions: transactions)

        let aiRewards = await generateAIRecommendedRewards(insights: insights, userId: userId)

        for reward in aiRewards {
            modelContext.insert(reward)
        }

        try? modelContext.save()
        return aiRewards
    }

    func shouldSendStreakReminder(loyaltyProfile: LoyaltyProfile) -> (should: Bool, message: String?) {
        guard let lastActivity = loyaltyProfile.lastActivityDate else {
            return (false, nil)
        }

        let calendar = Calendar.current
        let now = Date()
        let hoursSinceActivity = calendar.dateComponents([.hour], from: lastActivity, to: now).hour ?? 0

        if hoursSinceActivity >= 20, hoursSinceActivity < 24 {
            let streakDays = loyaltyProfile.streakDays
            let message = "Don't lose your \(streakDays)-day streak! Complete a transaction today."
            return (true, message)
        }

        return (false, nil)
    }

    // MARK: - Private Methods

    private func calculateBasePoints(for amount: Double, paymentType: PaymentType) -> Int {
        var basePoints = Int(amount * 10)

        switch paymentType {
        case .p2p:
            basePoints = Int(Double(basePoints) * 1.0)
        case .merchantContactless:
            basePoints = Int(Double(basePoints) * 1.2)
        case .merchantQRCode:
            basePoints = Int(Double(basePoints) * 1.3)
        case .merchantOnline:
            basePoints = Int(Double(basePoints) * 1.1)
        }

        return max(basePoints, 10)
    }

    private func checkAchievement(
        type: AchievementType,
        userId: String,
        transactions: [Transaction],
        loyaltyProfile: LoyaltyProfile,
        modelContext: ModelContext
    ) {
        let achievementDescriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate { achievement in
                achievement.userId == userId && achievement.type == type
            }
        )

        var achievement: Achievement
        if let existing = try? modelContext.fetch(achievementDescriptor).first {
            achievement = existing
        } else {
            achievement = Achievement(
                userId: userId,
                type: type,
                targetProgress: type.targetCount
            )
            modelContext.insert(achievement)
        }

        if achievement.isUnlocked { return }

        let progress = calculateProgress(for: type, transactions: transactions, loyaltyProfile: loyaltyProfile)
        achievement.updateProgress(progress)

        if achievement.isUnlocked {
            loyaltyProfile.addPoints(type.pointsReward)
        }

        try? modelContext.save()
    }

    private func calculateProgress(
        for type: AchievementType,
        transactions: [Transaction],
        loyaltyProfile: LoyaltyProfile
    ) -> Int {
        switch type {
        case .firstPayment:
            transactions.isEmpty ? 0 : 1
        case .tenP2PTransactions:
            transactions.count(where: { $0.paymentType == .p2p })
        case .twentyFiveP2PTransactions:
            transactions.count(where: { $0.paymentType == .p2p })
        case .fiftyP2PTransactions:
            transactions.count(where: { $0.paymentType == .p2p })
        case .firstMerchantPayment:
            transactions.filter { $0.paymentType != .p2p }.isEmpty ? 0 : 1
        case .tenMerchantPayments:
            transactions.count(where: { $0.paymentType != .p2p })
        case .fiftyMerchantPayments:
            transactions.count(where: { $0.paymentType != .p2p })
        case .weekStreak:
            loyaltyProfile.streakDays
        case .monthStreak:
            loyaltyProfile.streakDays
        case .reachedSilver:
            loyaltyProfile.currentLevel.pointsRequired >= 1000 ? 1 : 0
        case .reachedGold:
            loyaltyProfile.currentLevel.pointsRequired >= 5000 ? 1 : 0
        case .reachedPlatinum:
            loyaltyProfile.currentLevel.pointsRequired >= 10000 ? 1 : 0
        case .weroChampion:
            transactions.count
        case .bigSpender:
            transactions.contains { $0.amount >= 500 } ? 1 : 0
        case .savingsGoal:
            0
        }
    }

    private func analyzeUserBehavior(transactions: [Transaction]) -> UserBehaviorInsights {
        var p2pCount = 0
        var merchantCount = 0
        var totalSpent = 0.0
        var averageTransaction = 0.0
        var preferredPaymentType: PaymentType = .p2p
        var mostFrequentRecipient: String?

        var recipientCounts: [String: Int] = [:]

        for transaction in transactions {
            if transaction.paymentType == .p2p {
                p2pCount += 1
            } else {
                merchantCount += 1
            }

            totalSpent += transaction.amount

            recipientCounts[transaction.recipientName, default: 0] += 1
        }

        if !transactions.isEmpty {
            averageTransaction = totalSpent / Double(transactions.count)
        }

        preferredPaymentType = p2pCount > merchantCount ? .p2p : .merchantContactless

        mostFrequentRecipient = recipientCounts.max(by: { $0.value < $1.value })?.key

        return UserBehaviorInsights(
            p2pTransactionCount: p2pCount,
            merchantTransactionCount: merchantCount,
            totalSpent: totalSpent,
            averageTransactionAmount: averageTransaction,
            preferredPaymentType: preferredPaymentType,
            mostFrequentRecipient: mostFrequentRecipient,
            transactionFrequency: transactions.count
        )
    }

    private func generateAIRecommendedRewards(
        insights: UserBehaviorInsights,
        userId: String
    ) async -> [Reward] {
        var rewards: [Reward] = []

        if insights.p2pTransactionCount > insights.merchantTransactionCount {
            let p2pReward = Reward(
                userId: userId,
                title: "P2P Bonus",
                rewardDescription: "Get 5% cashback on your next P2P transfer",
                rewardType: .personalizedOffer,
                cashbackPercentage: 5.0,
                minTransactionAmount: 10.0,
                maxCashback: 25.0,
                isPersonalized: true
            )
            rewards.append(p2pReward)
        }

        if insights.merchantTransactionCount >= 5 {
            let merchantReward = Reward(
                userId: userId,
                title: "Merchant Master",
                rewardDescription: "Earn 3% cashback on merchant payments this week",
                rewardType: .personalizedOffer,
                cashbackPercentage: 3.0,
                minTransactionAmount: 20.0,
                maxCashback: 50.0,
                isPersonalized: true,
                maxUsages: 5
            )
            rewards.append(merchantReward)
        }

        if insights.averageTransactionAmount > 100 {
            let bigSpenderReward = Reward(
                userId: userId,
                title: "Big Spender Bonus",
                rewardDescription: "Extra 2% cashback on transactions over €100",
                rewardType: .personalizedOffer,
                cashbackPercentage: 2.0,
                minTransactionAmount: 100.0,
                maxCashback: 100.0,
                isPersonalized: true,
                maxUsages: 3
            )
            rewards.append(bigSpenderReward)
        }

        let generalReward = Reward(
            userId: userId,
            title: "Welcome Bonus",
            rewardDescription: "Complete any transaction and get 50 bonus points",
            rewardType: .bonusPoints,
            cashbackPercentage: 0.0,
            minTransactionAmount: 1.0,
            isPersonalized: false
        )
        rewards.append(generalReward)

        return rewards
    }
}

struct UserBehaviorInsights {
    let p2pTransactionCount: Int
    let merchantTransactionCount: Int
    let totalSpent: Double
    let averageTransactionAmount: Double
    let preferredPaymentType: PaymentType
    let mostFrequentRecipient: String?
    let transactionFrequency: Int
}
