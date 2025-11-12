//
//  TransactionHistoryView.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftData
import SwiftUI

struct TransactionHistoryView: View {
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.timestamp, order: .reverse) private var allTransactions: [Transaction]
    @Binding var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                if userTransactions.isEmpty {
                    ContentUnavailableView(
                        "Keine Transaktionen",
                        systemImage: "list.bullet.rectangle",
                        description: Text("Deine Zahlungen erscheinen hier")
                    )
                } else {
                    ForEach(userTransactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
            .navigationTitle("Transaktionsverlauf")
        }
    }

    private var userTransactions: [Transaction] {
        guard let currentUser = appState.currentUser else { return [] }
        return allTransactions.filter { $0.userId == currentUser.id }
    }
}

struct TransactionRow: View {
    // MARK: - Properties

    let transaction: Transaction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.recipientName)
                        .font(.headline)

                    Text(transaction.paymentType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(paymentTypeColor.opacity(0.2))
                        .foregroundStyle(paymentTypeColor)
                        .clipShape(Capsule())
                }

                Spacer()

                Text(String(format: "-%.2f €", transaction.amount))
                    .font(.headline)
                    .foregroundStyle(.sparkassenRed)
            }

            HStack {
                Text(transaction.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let notes = transaction.notes, !notes.isEmpty {
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var paymentTypeColor: Color {
        switch transaction.paymentType {
        case .p2p:
            .sparkassenDarkBlue
        case .merchantContactless:
            .sparkassenYellow
        case .merchantQRCode:
            .sparkassenOrange
        case .merchantOnline:
            .sparkassenLightBlue
        }
    }
}
