//
//  Reward.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Reward {
    // MARK: - Properties

    @Attribute(.unique) var id: String
    var userId: String
    var title: String
    var rewardDescription: String
    var rewardType: RewardType
    var cashbackPercentage: Double
    var minTransactionAmount: Double
    var maxCashback: Double
    var category: String?
    var merchantName: String?
    var isActive: Bool
    var isPersonalized: Bool
    var expiresAt: Date
    var createdAt: Date
    var usageCount: Int
    var maxUsages: Int

    // MARK: - Initializers

    init(id: String = UUID().uuidString,
         userId: String,
         title: String,
         rewardDescription: String,
         rewardType: RewardType,
         cashbackPercentage: Double,
         minTransactionAmount: Double = 0.0,
         maxCashback: Double = 50.0,
         category: String? = nil,
         merchantName: String? = nil,
         isActive: Bool = true,
         isPersonalized: Bool = false,
         expiresAt: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
         createdAt: Date = Date(),
         usageCount: Int = 0,
         maxUsages: Int = 1) {
        self.id = id
        self.userId = userId
        self.title = title
        self.rewardDescription = rewardDescription
        self.rewardType = rewardType
        self.cashbackPercentage = cashbackPercentage
        self.minTransactionAmount = minTransactionAmount
        self.maxCashback = maxCashback
        self.category = category
        self.merchantName = merchantName
        self.isActive = isActive
        self.isPersonalized = isPersonalized
        self.expiresAt = expiresAt
        self.createdAt = createdAt
        self.usageCount = usageCount
        self.maxUsages = maxUsages
    }

    // MARK: - Methods

    func canBeUsed() -> Bool {
        return isActive && usageCount < maxUsages && Date() < expiresAt
    }

    func use() {
        guard canBeUsed() else { return }
        usageCount += 1
        if usageCount >= maxUsages {
            isActive = false
        }
    }

    func calculateCashback(for amount: Double) -> Double {
        guard canBeUsed() && amount >= minTransactionAmount else { return 0.0 }
        let cashback = amount * (cashbackPercentage / 100.0)
        return min(cashback, maxCashback)
    }
}

enum RewardType: String, Codable {
    case cashback = "Cashback"
    case bonusPoints = "Bonus Points"
    case levelBonus = "Level Bonus"
    case streakBonus = "Streak Bonus"
    case categoryBonus = "Category Bonus"
    case merchantSpecific = "Merchant Specific"
    case personalizedOffer = "Personalized Offer"

    var icon: String {
        switch self {
        case .cashback:
            return "eurosign.circle.fill"
        case .bonusPoints:
            return "star.circle.fill"
        case .levelBonus:
            return "crown.fill"
        case .streakBonus:
            return "flame.fill"
        case .categoryBonus:
            return "tag.fill"
        case .merchantSpecific:
            return "building.2.fill"
        case .personalizedOffer:
            return "sparkles"
        }
    }
}
