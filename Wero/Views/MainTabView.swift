//
//  MainTabView.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    // MARK: - Properties

    @Binding var appState: AppState

    var body: some View {
        TabView {
            PaymentsView(appState: $appState)
                .tabItem {
                    Label("Zahlen", systemImage: "creditcard")
                }

            GamificationView()
                .tabItem {
                    Label("Rewards", systemImage: "trophy.fill")
                }

            TransactionHistoryView(appState: $appState)
                .tabItem {
                    Label("Verlauf", systemImage: "list.bullet.rectangle")
                }

            ProfileView(appState: $appState)
                .tabItem {
                    Label("Profil", systemImage: "person.circle")
                }
        }
    }
}
