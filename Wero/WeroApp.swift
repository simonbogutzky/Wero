//
//  WeroApp.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftData
import SwiftUI

@main
struct WeroApp: App {
    // MARK: - Properties

    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Contact.self,
            Merchant.self,
            Transaction.self,
            LoyaltyProfile.self,
            Achievement.self,
            Reward.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView(appState: $appState)
        }
        .modelContainer(sharedModelContainer)
    }
}
