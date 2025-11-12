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

        return true
    }
}
