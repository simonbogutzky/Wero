//
//  MerchantPaymentView.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftData
import SwiftUI

struct MerchantPaymentView: View {
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var merchants: [Merchant]
    @Binding var appState: AppState
    let paymentType: PaymentType

    @State private var selectedMerchant: Merchant?
    @State private var amount: String = ""
    @State private var showingConfirmation = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        Form {
            Section("Händler") {
                Picker("Händler auswählen", selection: $selectedMerchant) {
                    Text("Bitte wählen").tag(nil as Merchant?)
                    ForEach(filteredMerchants) { merchant in
                        Text(merchant.name).tag(merchant as Merchant?)
                    }
                }

                if let merchant = selectedMerchant {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(merchant.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(merchant.address)
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
                Button(actionButtonTitle) {
                    validateAndPay()
                }
                .disabled(!isFormValid)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Zahlung erfolgreich", isPresented: $showingConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            if let merchant = selectedMerchant {
                Text("Du hast \(amount) € bei \(merchant.name) bezahlt.")
            }
        }
        .alert("Fehler", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private var navigationTitle: String {
        switch paymentType {
        case .merchantContactless:
            "Kontaktlos zahlen"
        case .merchantQRCode:
            "QR-Code scannen"
        case .merchantOnline:
            "Online bezahlen"
        case .p2p:
            "P2P-Zahlung"
        }
    }

    private var actionButtonTitle: String {
        switch paymentType {
        case .merchantContactless:
            "Kontaktlos bezahlen"
        case .merchantQRCode:
            "Mit QR-Code bezahlen"
        case .merchantOnline:
            "Online bezahlen"
        case .p2p:
            "Senden"
        }
    }

    private var filteredMerchants: [Merchant] {
        if paymentType == .merchantOnline {
            return merchants.filter { $0.address == "Online" }
        } else {
            return merchants.filter { $0.address != "Online" }
        }
    }

    private var isFormValid: Bool {
        guard selectedMerchant != nil else { return false }
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")),
              amountValue > 0 else { return false }
        return true
    }

    // MARK: - Methods

    private func validateAndPay() {
        guard let merchant = selectedMerchant,
              let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            return
        }

        let success = appState.performTransaction(
            amount: amountValue,
            recipientName: merchant.name,
            recipientId: merchant.id,
            paymentType: paymentType,
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
