//
//  AppState.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation
import SwiftData

@Observable
final class AppState {
    // MARK: - Properties

    var currentUser: User?
    var isLoggedIn: Bool = false
    let loyaltyEngine = LoyaltyEngine()

    // MARK: - Methods

    func login(user: User) {
        currentUser = user
        isLoggedIn = true
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
    }

    func updateUserBalance(_ newBalance: Double, modelContext: ModelContext) {
        guard let currentUser else { return }
        currentUser.balance = newBalance
        try? modelContext.save()
    }

    func performTransaction(
        amount: Double,
        recipientName: String,
        recipientId: String,
        paymentType: PaymentType,
        notes: String? = nil,
        modelContext: ModelContext
    ) -> Bool {
        guard let currentUser, currentUser.balance >= amount else {
            return false
        }

        // Deduct amount from user balance
        currentUser.balance -= amount

        // Create transaction record
        let transaction = Transaction(
            userId: currentUser.id,
            amount: amount,
            recipientName: recipientName,
            recipientId: recipientId,
            paymentType: paymentType,
            notes: notes
        )

        modelContext.insert(transaction)
        try? modelContext.save()

        // Process loyalty points and achievements
        if let loyaltyProfile = getLoyaltyProfile(for: currentUser.id, modelContext: modelContext) {
            loyaltyEngine.processTransaction(
                amount: amount,
                paymentType: paymentType,
                loyaltyProfile: loyaltyProfile,
                modelContext: modelContext
            )
            loyaltyEngine.checkAndUnlockAchievements(
                userId: currentUser.id,
                loyaltyProfile: loyaltyProfile,
                modelContext: modelContext
            )
        }

        return true
    }

    func getLoyaltyProfile(for userId: String, modelContext: ModelContext) -> LoyaltyProfile? {
        let descriptor = FetchDescriptor<LoyaltyProfile>(
            predicate: #Predicate { $0.userId == userId }
        )

        if let profile = try? modelContext.fetch(descriptor).first {
            return profile
        }

        let newProfile = LoyaltyProfile(userId: userId)
        modelContext.insert(newProfile)
        try? modelContext.save()

        if let user = currentUser {
            user.loyaltyProfileId = newProfile.id
            try? modelContext.save()
        }

        return newProfile
    }
}
