//
//  ProfileView.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    // MARK: - Properties

    @Binding var appState: AppState

    var body: some View {
        NavigationStack {
            if let user = appState.currentUser {
                List {
                    Section("Benutzerdaten") {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(user.name)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("E-Mail")
                            Spacer()
                            Text(user.email)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("User-ID")
                            Spacer()
                            Text(user.id.prefix(8) + "...")
                                .foregroundStyle(.secondary)
                                .font(.system(.body, design: .monospaced))
                        }
                    }

                    Section("Account") {
                        HStack {
                            Text("Kontostand")
                            Spacer()
                            Text(String(format: "%.2f €", user.balance))
                                .foregroundStyle(.blue)
                                .fontWeight(.semibold)
                        }

                        HStack {
                            Text("Mitglied seit")
                            Spacer()
                            Text(user.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section {
                        Button(role: .destructive, action: {
                            appState.logout()
                        }) {
                            HStack {
                                Spacer()
                                Text("Benutzer wechseln")
                                Spacer()
                            }
                        }
                    }
                }
                .navigationTitle("Profil")
            }
        }
    }
}
