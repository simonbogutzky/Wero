//
//  WeroTests.swift
//  WeroTests
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftData
import Testing
@testable import Wero

struct WeroTests {
    @Test func testUserCreation() async throws {
        let user = User(name: "Test User", email: "test@example.com", balance: 500.0)
        #expect(user.name == "Test User")
        #expect(user.email == "test@example.com")
        #expect(user.balance == 500.0)
    }

    @Test func testContactCreation() async throws {
        let contact = Contact(name: "Jane Doe", email: "jane@example.com", phoneNumber: "+49 151 12345678")
        #expect(contact.name == "Jane Doe")
        #expect(contact.email == "jane@example.com")
        #expect(contact.phoneNumber == "+49 151 12345678")
    }

    @Test func testMerchantCreation() async throws {
        let merchant = Merchant(name: "Test Shop", category: "Retail", address: "Main St 1")
        #expect(merchant.name == "Test Shop")
        #expect(merchant.category == "Retail")
        #expect(merchant.address == "Main St 1")
    }

    @Test func testTransactionCreation() async throws {
        let transaction = Transaction(
            userId: "user123",
            amount: 50.0,
            recipientName: "Test Merchant",
            recipientId: "merchant123",
            paymentType: .p2p
        )
        #expect(transaction.amount == 50.0)
        #expect(transaction.recipientName == "Test Merchant")
        #expect(transaction.paymentType == .p2p)
    }

    @Test func testAppStateLogin() async throws {
        let appState = AppState()
        let user = User(name: "Test User", email: "test@example.com")

        #expect(appState.isLoggedIn == false)
        #expect(appState.currentUser == nil)

        appState.login(user: user)
        #expect(appState.isLoggedIn == true)
        #expect(appState.currentUser?.name == "Test User")
    }

    @Test func testAppStateLogout() async throws {
        let appState = AppState()
        let user = User(name: "Test User", email: "test@example.com")

        appState.login(user: user)
        #expect(appState.isLoggedIn == true)

        appState.logout()
        #expect(appState.isLoggedIn == false)
        #expect(appState.currentUser == nil)
    }

    @Test func testPaymentTypeDisplayName() async throws {
        #expect(PaymentType.p2p.displayName == "P2P")
        #expect(PaymentType.merchantContactless.displayName == "Contactless")
        #expect(PaymentType.merchantQRCode.displayName == "QR-Code")
        #expect(PaymentType.merchantOnline.displayName == "Online")
    }
}
