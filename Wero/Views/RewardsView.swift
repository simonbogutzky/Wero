//
//  RewardsView.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftData
import SwiftUI

struct RewardsView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var appState: AppState

    @Query private var rewards: [Reward]

    @State private var selectedFilter: RewardFilter = .all

    var filteredRewards: [Reward] {
        guard let userId = appState.currentUser?.id else { return [] }

        let userRewards = rewards.filter { $0.userId == userId }

        switch selectedFilter {
        case .all:
            return userRewards
        case .active:
            return userRewards.filter { $0.canBeUsed() }
        case .expired:
            return userRewards.filter { !$0.canBeUsed() }
        case .personalized:
            return userRewards.filter { $0.isPersonalized && $0.canBeUsed() }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterPicker

                if filteredRewards.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredRewards, id: \.id) { reward in
                                rewardDetailCard(reward: reward)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Rewards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Methods

    @ViewBuilder
    private var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            Text("All").tag(RewardFilter.all)
            Text("Active").tag(RewardFilter.active)
            Text("Personalized").tag(RewardFilter.personalized)
            Text("Expired").tag(RewardFilter.expired)
        }
        .pickerStyle(.segmented)
        .padding()
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "gift.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Rewards Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Complete more transactions to unlock personalized rewards and cashback offers!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func rewardDetailCard(reward: Reward) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: reward.rewardType.icon)
                    .font(.title2)
                    .foregroundColor(.sparkassenRed)

                Text(reward.title)
                    .font(.headline)

                Spacer()

                if reward.isPersonalized {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("AI")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.sparkassenDarkBlue)
                    .cornerRadius(8)
                }
            }

            Text(reward.rewardDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                rewardInfoRow(
                    icon: "percent",
                    label: "Cashback",
                    value: "\(Int(reward.cashbackPercentage))%"
                )

                rewardInfoRow(
                    icon: "eurosign.circle",
                    label: "Min. Amount",
                    value: "€\(String(format: "%.2f", reward.minTransactionAmount))"
                )

                rewardInfoRow(
                    icon: "arrow.up.circle",
                    label: "Max Cashback",
                    value: "€\(String(format: "%.2f", reward.maxCashback))"
                )

                rewardInfoRow(
                    icon: "number.circle",
                    label: "Usage",
                    value: "\(reward.usageCount)/\(reward.maxUsages)"
                )

                if let category = reward.category {
                    rewardInfoRow(
                        icon: "tag",
                        label: "Category",
                        value: category
                    )
                }

                if let merchant = reward.merchantName {
                    rewardInfoRow(
                        icon: "building.2",
                        label: "Merchant",
                        value: merchant
                    )
                }
            }

            Divider()

            HStack {
                Label(
                    reward.canBeUsed() ? "Active" : "Expired",
                    systemImage: reward.canBeUsed() ? "checkmark.circle.fill" : "xmark.circle.fill"
                )
                .font(.caption)
                .foregroundColor(reward.canBeUsed() ? .sparkassenYellow : .sparkassenRed)

                Spacer()

                Label(
                    "Expires \(reward.expiresAt, style: .date)",
                    systemImage: "clock"
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .opacity(reward.canBeUsed() ? 1.0 : 0.6)
    }

    @ViewBuilder
    private func rewardInfoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

enum RewardFilter {
    case all
    case active
    case expired
    case personalized
}
