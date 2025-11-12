//
//  MockDataService.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation
import SwiftData

@Observable
final class MockDataService {
    // MARK: - Properties

    static let shared = MockDataService()

    // MARK: - Initializers

    private init() {}

    // MARK: - Methods

    func setupMockData(modelContext: ModelContext) {
        // Create mock users
        let users = createMockUsers()
        users.forEach { modelContext.insert($0) }

        // Create mock contacts
        let contacts = createMockContacts()
        contacts.forEach { modelContext.insert($0) }

        // Create mock merchants
        let merchants = createMockMerchants()
        merchants.forEach { modelContext.insert($0) }

        // Save context
        try? modelContext.save()
    }

    func createMockUsers() -> [User] {
        [
            User(name: "Max Mustermann", email: "max@example.com", balance: 1500.0),
            User(name: "Anna Schmidt", email: "anna@example.com", balance: 2000.0),
            User(name: "Tom Weber", email: "tom@example.com", balance: 750.0)
        ]
    }

    func createMockContacts() -> [Contact] {
        [
            Contact(name: "Lisa Müller", email: "lisa@example.com", phoneNumber: "+49 151 12345678"),
            Contact(name: "Michael Koch", email: "michael@example.com", phoneNumber: "+49 152 23456789"),
            Contact(name: "Sarah Wagner", email: "sarah@example.com", phoneNumber: "+49 153 34567890"),
            Contact(name: "David Becker", email: "david@example.com", phoneNumber: "+49 154 45678901"),
            Contact(name: "Julia Fischer", email: "julia@example.com", phoneNumber: "+49 155 56789012")
        ]
    }

    func createMockMerchants() -> [Merchant] {
        [
            Merchant(name: "REWE Supermarkt", category: "Lebensmittel", address: "Hauptstraße 1, 10115 Berlin"),
            Merchant(name: "Media Markt", category: "Elektronik", address: "Kurfürstendamm 20, 10719 Berlin"),
            Merchant(name: "H&M", category: "Bekleidung", address: "Tauentzienstraße 7, 10789 Berlin"),
            Merchant(name: "Starbucks", category: "Café", address: "Friedrichstraße 50, 10117 Berlin"),
            Merchant(name: "Amazon", category: "Online-Shop", address: "Online"),
            Merchant(name: "Tankstelle Shell", category: "Tankstelle", address: "Bundesallee 100, 10715 Berlin")
        ]
    }
}
