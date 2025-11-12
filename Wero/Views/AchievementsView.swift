//
//  AchievementsView.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftData
import SwiftUI

struct AchievementsView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var appState: AppState

    @Query private var achievements: [Achievement]

    @State private var selectedFilter: AchievementFilter = .all

    var filteredAchievements: [Achievement] {
        guard let userId = appState.currentUser?.id else { return [] }

        let userAchievements = achievements.filter { $0.userId == userId }

        switch selectedFilter {
        case .all:
            return userAchievements
        case .unlocked:
            return userAchievements.filter(\.isUnlocked)
        case .locked:
            return userAchievements.filter { !$0.isUnlocked }
        }
    }

    var unlockedCount: Int {
        guard let userId = appState.currentUser?.id else { return 0 }
        return achievements.count(where: { $0.userId == userId && $0.isUnlocked })
    }

    var totalCount: Int {
        guard let userId = appState.currentUser?.id else { return 0 }
        return achievements.count(where: { $0.userId == userId })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressHeader

                filterPicker

                if filteredAchievements.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                            ForEach(filteredAchievements, id: \.id) { achievement in
                                achievementCard(achievement: achievement)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Achievements")
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
    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundColor(.sparkassenRed)

                Text("\(unlockedCount) / \(totalCount)")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }

            ProgressView(value: Double(unlockedCount), total: Double(max(totalCount, 1)))
                .tint(.sparkassenRed)

            HStack {
                Text("\(Int((Double(unlockedCount) / Double(max(totalCount, 1))) * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(totalCount - unlockedCount) remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }

    @ViewBuilder
    private var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            Text("All").tag(AchievementFilter.all)
            Text("Unlocked").tag(AchievementFilter.unlocked)
            Text("Locked").tag(AchievementFilter.locked)
        }
        .pickerStyle(.segmented)
        .padding()
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Achievements Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Complete transactions to unlock achievements and earn bonus points!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func achievementCard(achievement: Achievement) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.sparkassenRed.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: achievement.type.icon)
                    .font(.system(size: 36))
                    .foregroundColor(achievement.isUnlocked ? .sparkassenRed : .gray)
            }

            VStack(spacing: 4) {
                Text(achievement.type.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(achievement.type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            if achievement.isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.sparkassenYellow)

                    Text("Unlocked")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.sparkassenYellow)
            } else {
                VStack(spacing: 4) {
                    ProgressView(value: Double(achievement.progress), total: Double(achievement.targetProgress))
                        .tint(.sparkassenRed)

                    Text("\(achievement.progress) / \(achievement.targetProgress)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.sparkassenYellow)

                Text("+\(achievement.type.pointsReward) pts")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .frame(height: 240)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ? Color.sparkassenRed : Color.clear, lineWidth: 2)
        )
    }
}

enum AchievementFilter {
    case all
    case unlocked
    case locked
}
