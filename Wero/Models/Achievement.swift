//
//  Achievement.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Achievement {
    // MARK: - Properties

    @Attribute(.unique) var id: String
    var userId: String
    var type: AchievementType
    var isUnlocked: Bool
    var unlockedAt: Date?
    var progress: Int
    var targetProgress: Int
    var createdAt: Date

    // MARK: - Initializers

    init(id: String = UUID().uuidString,
         userId: String,
         type: AchievementType,
         isUnlocked: Bool = false,
         unlockedAt: Date? = nil,
         progress: Int = 0,
         targetProgress: Int = 1,
         createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.type = type
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        self.progress = progress
        self.targetProgress = targetProgress
        self.createdAt = createdAt
    }

    // MARK: - Methods

    func updateProgress(_ newProgress: Int) {
        progress = newProgress
        if progress >= targetProgress && !isUnlocked {
            unlock()
        }
    }

    func unlock() {
        isUnlocked = true
        unlockedAt = Date()
    }
}

enum AchievementType: String, Codable, CaseIterable {
    case firstPayment = "First Payment"
    case tenP2PTransactions = "10 P2P Transactions"
    case twentyFiveP2PTransactions = "25 P2P Transactions"
    case fiftyP2PTransactions = "50 P2P Transactions"
    case firstMerchantPayment = "First Merchant Payment"
    case tenMerchantPayments = "10 Merchant Payments"
    case fiftyMerchantPayments = "50 Merchant Payments"
    case weekStreak = "Week Streak"
    case monthStreak = "Month Streak"
    case reachedSilver = "Silver Level"
    case reachedGold = "Gold Level"
    case reachedPlatinum = "Platinum Level"
    case weroChampion = "Wero Champion"
    case bigSpender = "Big Spender"
    case savingsGoal = "Savings Goal"

    var title: String {
        return rawValue
    }

    var description: String {
        switch self {
        case .firstPayment:
            return "Completed your first Wero payment"
        case .tenP2PTransactions:
            return "Completed 10 person-to-person transfers"
        case .twentyFiveP2PTransactions:
            return "Completed 25 person-to-person transfers"
        case .fiftyP2PTransactions:
            return "Completed 50 person-to-person transfers"
        case .firstMerchantPayment:
            return "Made your first merchant payment"
        case .tenMerchantPayments:
            return "Completed 10 merchant payments"
        case .fiftyMerchantPayments:
            return "Completed 50 merchant payments"
        case .weekStreak:
            return "Maintained a 7-day activity streak"
        case .monthStreak:
            return "Maintained a 30-day activity streak"
        case .reachedSilver:
            return "Reached Silver loyalty level"
        case .reachedGold:
            return "Reached Gold loyalty level"
        case .reachedPlatinum:
            return "Reached Platinum loyalty level"
        case .weroChampion:
            return "Became a Wero Champion with 100+ transactions"
        case .bigSpender:
            return "Completed a transaction over €500"
        case .savingsGoal:
            return "Maintained balance above €1000"
        }
    }

    var icon: String {
        switch self {
        case .firstPayment:
            return "checkmark.circle.fill"
        case .tenP2PTransactions, .twentyFiveP2PTransactions, .fiftyP2PTransactions:
            return "person.2.fill"
        case .firstMerchantPayment, .tenMerchantPayments, .fiftyMerchantPayments:
            return "cart.fill"
        case .weekStreak, .monthStreak:
            return "flame.fill"
        case .reachedSilver:
            return "star.fill"
        case .reachedGold:
            return "crown.fill"
        case .reachedPlatinum:
            return "sparkles"
        case .weroChampion:
            return "trophy.fill"
        case .bigSpender:
            return "eurosign.circle.fill"
        case .savingsGoal:
            return "banknote.fill"
        }
    }

    var targetCount: Int {
        switch self {
        case .firstPayment, .firstMerchantPayment:
            return 1
        case .tenP2PTransactions, .tenMerchantPayments:
            return 10
        case .twentyFiveP2PTransactions:
            return 25
        case .fiftyP2PTransactions, .fiftyMerchantPayments:
            return 50
        case .weekStreak:
            return 7
        case .monthStreak:
            return 30
        case .reachedSilver, .reachedGold, .reachedPlatinum:
            return 1
        case .weroChampion:
            return 100
        case .bigSpender:
            return 1
        case .savingsGoal:
            return 1
        }
    }

    var pointsReward: Int {
        switch self {
        case .firstPayment, .firstMerchantPayment:
            return 50
        case .tenP2PTransactions, .tenMerchantPayments:
            return 100
        case .twentyFiveP2PTransactions:
            return 250
        case .fiftyP2PTransactions, .fiftyMerchantPayments:
            return 500
        case .weekStreak:
            return 200
        case .monthStreak:
            return 1000
        case .reachedSilver:
            return 300
        case .reachedGold:
            return 800
        case .reachedPlatinum:
            return 2000
        case .weroChampion:
            return 1500
        case .bigSpender:
            return 400
        case .savingsGoal:
            return 300
        }
    }
}
