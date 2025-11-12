//
//  LoyaltyEngine.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation
import FoundationModels
import SwiftData

// MARK: - AI Reward Generation Structures

@Generable
struct AIRewardRecommendation {
    @Guide(description: "Title of the personalized reward offer")
    let title: String

    @Guide(description: "Detailed description of the reward and how to earn it")
    let description: String

    @Guide(description: "Cashback percentage for this reward", .range(1.0 ... 10.0))
    let cashbackPercentage: Double

    @Guide(description: "Minimum transaction amount required in euros", .range(1.0 ... 1000.0))
    let minTransactionAmount: Double

    @Guide(description: "Maximum cashback amount in euros", .range(5.0 ... 200.0))
    let maxCashback: Double

    @Guide(description: "Maximum number of times this reward can be used", .range(1 ... 10))
    let maxUsages: Int

    @Guide(description: "Type of reward: bonusPoints, cashback, or personalizedOffer")
    let rewardType: String
}

@Generable
struct AIRewardAnalysis {
    @Guide(description: "List of 2-4 personalized reward recommendations based on user behavior")
    let recommendations: [AIRewardRecommendation]

    @Guide(description: "Brief explanation of why these rewards were recommended")
    let rationale: String
}

@Observable
final class LoyaltyEngine {
    // MARK: - Properties

    var isProcessing: Bool = false
    private var languageModelSession: LanguageModelSession?
    private var isAIAvailable: Bool {
        let systemModel = SystemLanguageModel.default
        switch systemModel.availability {
        case .available:
            return true
        case .unavailable:
            return false
        }
    }

    // MARK: - Initialization

    init() {
        initializeLanguageModel()
    }

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

        var newRewards: [Reward] = []
        for reward in aiRewards {
            if !rewardExists(title: reward.title, userId: userId, modelContext: modelContext) {
                modelContext.insert(reward)
                newRewards.append(reward)
            }
        }

        try? modelContext.save()
        return newRewards
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

    private func initializeLanguageModel() {
        guard isAIAvailable else {
            return
        }

        let instructions = Instructions("""
        You are a financial rewards expert specializing in personalized loyalty programs.
        Your task is to analyze user transaction behavior and create compelling, personalized reward offers.

        Guidelines:
        - Recommend 2-4 relevant rewards based on the user's transaction patterns
        - Focus on rewards that align with their spending habits
        - Be creative but realistic with cashback percentages (1-10%)
        - Ensure rewards are achievable and motivating
        - Provide clear, engaging descriptions
        - Consider both P2P and merchant transaction preferences
        - Balance between bonusPoints, cashback, and personalizedOffer types

        Your recommendations should feel personal and valuable to the user.
        """)

        languageModelSession = LanguageModelSession(instructions: instructions)

        // Prewarm the model for better performance
        Task {
            languageModelSession?.prewarm()
        }
    }

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

    private func rewardExists(
        title: String,
        userId: String,
        modelContext: ModelContext
    ) -> Bool {
        let descriptor = FetchDescriptor<Reward>(
            predicate: #Predicate { reward in
                reward.userId == userId && reward.title == title
            }
        )

        guard let existingRewards = try? modelContext.fetch(descriptor) else { return false }
        return !existingRewards.isEmpty
    }

    private func generateAIRecommendedRewards(
        insights: UserBehaviorInsights,
        userId: String
    ) async -> [Reward] {
        // If AI is not available, fall back to rule-based rewards
        guard isAIAvailable, let session = languageModelSession else {
            return generateFallbackRewards(insights: insights, userId: userId)
        }

        do {
            // Create a detailed prompt with user behavior insights
            let prompt = Prompt("""
            Analyze this user's transaction behavior and recommend personalized rewards:

            Transaction Statistics:
            - P2P Transactions: \(insights.p2pTransactionCount)
            - Merchant Transactions: \(insights.merchantTransactionCount)
            - Total Spent: €\(String(format: "%.2f", insights.totalSpent))
            - Average Transaction: €\(String(format: "%.2f", insights.averageTransactionAmount))
            - Preferred Payment Type: \(insights.preferredPaymentType.rawValue)
            - Transaction Frequency: \(insights.transactionFrequency) transactions
            \(insights.mostFrequentRecipient.map { "- Most Frequent Recipient: \($0)" } ?? "")

            Generate personalized reward recommendations that will motivate this user.
            """)

            // Request structured AI recommendations
            let response = try await session.respond(to: prompt, generating: AIRewardAnalysis.self)

            // Convert AI recommendations to Reward objects
            var rewards: [Reward] = []
            for aiReward in response.content.recommendations {
                let rewardType: RewardType = switch aiReward.rewardType.lowercased() {
                case "bonuspoints": .bonusPoints
                case "cashback": .cashback
                default: .personalizedOffer
                }

                let reward = Reward(
                    userId: userId,
                    title: aiReward.title,
                    rewardDescription: aiReward.description,
                    rewardType: rewardType,
                    cashbackPercentage: aiReward.cashbackPercentage,
                    minTransactionAmount: aiReward.minTransactionAmount,
                    maxCashback: aiReward.maxCashback,
                    isPersonalized: true,
                    maxUsages: aiReward.maxUsages
                )
                rewards.append(reward)
            }

            return rewards

        } catch {
            // Log error and fall back to rule-based rewards
            print("AI reward generation failed: \(error). Using fallback rewards.")
            return generateFallbackRewards(insights: insights, userId: userId)
        }
    }

    private func generateFallbackRewards(
        insights: UserBehaviorInsights,
        userId: String
    ) -> [Reward] {
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
