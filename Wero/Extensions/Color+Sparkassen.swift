//
//  Color+Sparkassen.swift
//  Wero
//
//  Sparkassen Design System Color Extension
//

import SwiftUI

extension Color {
    // MARK: - Primary Brand Colors

    /// Primary Sparkassen brand color (RGB 255/0/0)
    static let sparkassenRed = Color("SparkassenRed")

    /// Secondary brand color for text and UI elements
    static let sparkassenDarkGray = Color("SparkassenDarkGray")

    /// Secondary brand color for professional accents
    static let sparkassenDarkBlue = Color("SparkassenDarkBlue")

    // MARK: - Accent Colors

    /// Accent color for highlights and notifications
    static let sparkassenOrange = Color("SparkassenOrange")

    /// Accent color for rewards and achievements
    static let sparkassenYellow = Color("SparkassenYellow")

    /// Accent color for information and secondary actions
    static let sparkassenLightBlue = Color("SparkassenLightBlue")

    // MARK: - Loyalty Level Colors

    /// Bronze level color
    static let loyaltyBronze = Color(red: 0.804, green: 0.498, blue: 0.196)

    /// Silver level color
    static let loyaltySilver = Color(red: 0.753, green: 0.753, blue: 0.753)

    /// Gold level color
    static let loyaltyGold = sparkassenYellow

    /// Platinum level color
    static let loyaltyPlatinum = sparkassenDarkBlue
}
