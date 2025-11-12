//
//  LoginView.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftData
import SwiftUI

struct LoginView: View {
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Binding var appState: AppState

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "eurosign.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Wero")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Wähle einen Benutzer aus")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top)

                if users.isEmpty {
                    Button("Setup Mock Data") {
                        setupMockData()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    List {
                        ForEach(users) { user in
                            Button(action: {
                                appState.login(user: user)
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.name)
                                            .font(.headline)
                                        Text(user.email)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(String(format: "%.2f €", user.balance))
                                        .font(.headline)
                                        .foregroundStyle(.blue)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("Login")
        }
    }

    // MARK: - Methods

    private func setupMockData() {
        MockDataService.shared.setupMockData(modelContext: modelContext)
    }
}
