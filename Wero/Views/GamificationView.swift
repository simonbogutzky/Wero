//
//  GamificationView.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftData
import SwiftUI

struct GamificationView: View {
    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Binding var appState: AppState

    @Query private var loyaltyProfiles: [LoyaltyProfile]
    @Query private var achievements: [Achievement]
    @Query private var rewards: [Reward]

    @State private var showRewardsSheet = false
    @State private var showAchievementsSheet = false
    @State private var isGeneratingRewards = false

    var loyaltyProfile: LoyaltyProfile? {
        guard let userId = appState.currentUser?.id else { return nil }
        return loyaltyProfiles.first { $0.userId == userId }
    }

    var userAchievements: [Achievement] {
        guard let userId = appState.currentUser?.id else { return [] }
        return achievements.filter { $0.userId == userId }
    }

    var userRewards: [Reward] {
        guard let userId = appState.currentUser?.id else { return [] }
        return rewards.filter { $0.userId == userId && $0.canBeUsed() }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let profile = loyaltyProfile {
                        levelCard(profile: profile)
                        streakCard(profile: profile)
                        statsCard(profile: profile)
                        rewardsSection
                        achievementsSection
                    } else {
                        Text("Loading loyalty profile...")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Smart Rewards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: generatePersonalizedRewards) {
                        if isGeneratingRewards {
                            ProgressView()
                        } else {
                            Image(systemName: "sparkles")
                        }
                    }
                    .disabled(isGeneratingRewards)
                }
            }
            .sheet(isPresented: $showRewardsSheet) {
                RewardsView(appState: $appState)
            }
            .sheet(isPresented: $showAchievementsSheet) {
                AchievementsView(appState: $appState)
            }
        }
    }

    // MARK: - Methods

    @ViewBuilder
    private func levelCard(profile: LoyaltyProfile) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: profile.currentLevel.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.currentLevel.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(profile.totalPoints) points")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(profile.levelProgress * 100))%")
                        .font(.headline)

                    if profile.nextLevelPoints > 0 {
                        Text("\(profile.nextLevelPoints - profile.totalPoints) to next")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Max Level")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            ProgressView(value: profile.levelProgress)
                .tint(.accentColor)

            HStack {
                Label("\(Int(profile.currentLevel.cashbackRate * 100))% Cashback", systemImage: "eurosign.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Label("€\(String(format: "%.2f", profile.cashbackEarned)) earned", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    @ViewBuilder
    private func streakCard(profile: LoyaltyProfile) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 36))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(profile.streakDays) Day Streak")
                    .font(.headline)

                Text("\(String(format: "%.1f", profile.streakMultiplier))x Points Multiplier")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let lastActivity = profile.lastActivityDate {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Last Active")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(lastActivity, style: .relative)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    @ViewBuilder
    private func statsCard(profile: LoyaltyProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)

            HStack(spacing: 20) {
                statItem(title: "Total Points", value: "\(profile.totalPoints)", icon: "star.fill")
                statItem(title: "Streak Days", value: "\(profile.streakDays)", icon: "flame.fill")
                statItem(title: "Cashback", value: "€\(String(format: "%.0f", profile.cashbackEarned))", icon: "eurosign.circle.fill")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    @ViewBuilder
    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)

            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var rewardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Rewards")
                    .font(.headline)

                Spacer()

                Button("View All") {
                    showRewardsSheet = true
                }
                .font(.caption)
            }

            if userRewards.isEmpty {
                Text("No active rewards. Complete transactions to unlock personalized offers!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(userRewards.prefix(3), id: \.id) { reward in
                            rewardCard(reward: reward)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    @ViewBuilder
    private func rewardCard(reward: Reward) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: reward.rewardType.icon)
                    .foregroundColor(.accentColor)

                Spacer()

                if reward.isPersonalized {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }

            Text(reward.title)
                .font(.headline)
                .lineLimit(1)

            Text(reward.rewardDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Text("\(Int(reward.cashbackPercentage))% Back")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)

                Spacer()

                Text("Expires \(reward.expiresAt, style: .relative)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }

    @ViewBuilder
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)

                Spacer()

                Button("View All") {
                    showAchievementsSheet = true
                }
                .font(.caption)
            }

            let unlockedAchievements = userAchievements.filter(\.isUnlocked).prefix(3)

            if unlockedAchievements.isEmpty {
                Text("Complete transactions to unlock achievements!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(unlockedAchievements), id: \.id) { achievement in
                        achievementRow(achievement: achievement)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    @ViewBuilder
    private func achievementRow(achievement: Achievement) -> some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.type.icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.type.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(achievement.type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let unlockedAt = achievement.unlockedAt {
                Text(unlockedAt, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func generatePersonalizedRewards() {
        guard let userId = appState.currentUser?.id else { return }

        isGeneratingRewards = true

        Task {
            _ = await appState.loyaltyEngine.generatePersonalizedRewards(
                userId: userId,
                modelContext: modelContext
            )

            await MainActor.run {
                isGeneratingRewards = false
            }
        }
    }
}
