//
//  User.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class User {
    // MARK: - Properties

    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var balance: Double
    var loyaltyProfileId: String?
    var createdAt: Date

    // MARK: - Initializers

    init(id: String = UUID().uuidString, name: String, email: String, balance: Double = 1000.0, loyaltyProfileId: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.balance = balance
        self.loyaltyProfileId = loyaltyProfileId
        self.createdAt = Date()
    }
}
