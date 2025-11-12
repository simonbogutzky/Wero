//
//  P2PPaymentView.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftData
import SwiftUI

struct P2PPaymentView: View {
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var contacts: [Contact]
    @Binding var appState: AppState

    @State private var selectedContact: Contact?
    @State private var amount: String = ""
    @State private var notes: String = ""
    @State private var showingConfirmation = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        Form {
            Section("Empfänger") {
                Picker("Kontakt auswählen", selection: $selectedContact) {
                    Text("Bitte wählen").tag(nil as Contact?)
                    ForEach(contacts) { contact in
                        Text(contact.name).tag(contact as Contact?)
                    }
                }

                if let contact = selectedContact {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(contact.email)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(contact.phoneNumber)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Betrag") {
                HStack {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                    Text("€")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Notiz (optional)") {
                TextField("z.B. Danke für gestern", text: $notes)
            }

            if let user = appState.currentUser {
                Section {
                    HStack {
                        Text("Verfügbares Guthaben")
                        Spacer()
                        Text(String(format: "%.2f €", user.balance))
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                }
            }

            Section {
                Button("Geld senden") {
                    validateAndSend()
                }
                .disabled(!isFormValid)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("P2P-Zahlung")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Zahlung erfolgreich", isPresented: $showingConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            if let contact = selectedContact {
                Text("Du hast \(amount) € an \(contact.name) gesendet.")
            }
        }
        .alert("Fehler", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private var isFormValid: Bool {
        guard selectedContact != nil else { return false }
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")),
              amountValue > 0 else { return false }
        return true
    }

    // MARK: - Methods

    private func validateAndSend() {
        guard let contact = selectedContact,
              let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            return
        }

        let success = appState.performTransaction(
            amount: amountValue,
            recipientName: contact.name,
            recipientId: contact.id,
            paymentType: .p2p,
            notes: notes.isEmpty ? nil : notes,
            modelContext: modelContext
        )

        if success {
            showingConfirmation = true
        } else {
            errorMessage = "Unzureichendes Guthaben"
            showingError = true
        }
    }
}
