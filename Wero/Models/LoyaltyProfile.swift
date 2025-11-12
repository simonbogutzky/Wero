//
//  LoyaltyProfile.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class LoyaltyProfile {
    // MARK: - Properties

    @Attribute(.unique) var id: String
    var userId: String
    var totalPoints: Int
    var currentLevel: LoyaltyLevel
    var levelProgress: Double
    var streakDays: Int
    var lastActivityDate: Date?
    var streakMultiplier: Double
    var cashbackEarned: Double
    var nextLevelPoints: Int
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Initializers

    init(id: String = UUID().uuidString,
         userId: String,
         totalPoints: Int = 0,
         currentLevel: LoyaltyLevel = .bronze,
         levelProgress: Double = 0.0,
         streakDays: Int = 0,
         lastActivityDate: Date? = nil,
         streakMultiplier: Double = 1.0,
         cashbackEarned: Double = 0.0,
         nextLevelPoints: Int = 1000,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.totalPoints = totalPoints
        self.currentLevel = currentLevel
        self.levelProgress = levelProgress
        self.streakDays = streakDays
        self.lastActivityDate = lastActivityDate
        self.streakMultiplier = streakMultiplier
        self.cashbackEarned = cashbackEarned
        self.nextLevelPoints = nextLevelPoints
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Methods

    func updateStreak(currentDate: Date = Date()) {
        guard let lastDate = lastActivityDate else {
            streakDays = 1
            lastActivityDate = currentDate
            streakMultiplier = 1.0
            return
        }

        let calendar = Calendar.current
        let daysDifference = calendar.dateComponents([.day], from: lastDate, to: currentDate).day ?? 0

        if daysDifference == 1 {
            streakDays += 1
            streakMultiplier = min(3.0, 1.0 + Double(streakDays) * 0.1)
        } else if daysDifference > 1 {
            streakDays = 1
            streakMultiplier = 1.0
        }

        lastActivityDate = currentDate
        updatedAt = currentDate
    }

    func addPoints(_ points: Int) {
        let earnedPoints = Int(Double(points) * streakMultiplier)
        totalPoints += earnedPoints
        updateLevel()
        updatedAt = Date()
    }

    func addCashback(_ amount: Double) {
        cashbackEarned += amount
        updatedAt = Date()
    }

    private func updateLevel() {
        let previousLevel = currentLevel

        if totalPoints >= 10000 {
            currentLevel = .platinum
            nextLevelPoints = 0
        } else if totalPoints >= 5000 {
            currentLevel = .gold
            nextLevelPoints = 10000
        } else if totalPoints >= 1000 {
            currentLevel = .silver
            nextLevelPoints = 5000
        } else {
            currentLevel = .bronze
            nextLevelPoints = 1000
        }

        if currentLevel != previousLevel {
            levelProgress = 0.0
        } else {
            let levelStart = currentLevel.pointsRequired
            let levelEnd = nextLevelPoints
            levelProgress = Double(totalPoints - levelStart) / Double(levelEnd - levelStart)
        }
    }
}

enum LoyaltyLevel: String, Codable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"

    var pointsRequired: Int {
        switch self {
        case .bronze: 0
        case .silver: 1000
        case .gold: 5000
        case .platinum: 10000
        }
    }

    var cashbackRate: Double {
        switch self {
        case .bronze: 0.01
        case .silver: 0.02
        case .gold: 0.03
        case .platinum: 0.05
        }
    }

    var icon: String {
        switch self {
        case .bronze: "medal.fill"
        case .silver: "star.fill"
        case .gold: "crown.fill"
        case .platinum: "sparkles"
        }
    }

    var color: String {
        switch self {
        case .bronze: "brown"
        case .silver: "gray"
        case .gold: "yellow"
        case .platinum: "purple"
        }
    }
}
