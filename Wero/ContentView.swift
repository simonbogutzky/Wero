//
//  ContentView.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    // MARK: - Properties

    @Binding var appState: AppState

    // MARK: - Body

    var body: some View {
        if appState.isLoggedIn {
            MainTabView(appState: $appState)
        } else {
            LoginView(appState: $appState)
        }
    }
}

#Preview {
    ContentView(appState: .constant(AppState()))
        .modelContainer(for: User.self, inMemory: true)
}
