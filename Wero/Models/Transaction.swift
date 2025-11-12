//
//  Transaction.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    // MARK: - Properties

    @Attribute(.unique) var id: String
    var userId: String
    var amount: Double
    var recipientName: String
    var recipientId: String
    var paymentType: PaymentType
    var timestamp: Date
    var notes: String?

    // MARK: - Initializers

    init(
        id: String = UUID().uuidString,
        userId: String,
        amount: Double,
        recipientName: String,
        recipientId: String,
        paymentType: PaymentType,
        timestamp: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.amount = amount
        self.recipientName = recipientName
        self.recipientId = recipientId
        self.paymentType = paymentType
        self.timestamp = timestamp
        self.notes = notes
    }
}
