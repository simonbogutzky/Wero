//
//  PaymentType.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation

enum PaymentType: String, Codable {
    case p2p = "P2P"
    case merchantContactless = "Contactless"
    case merchantQRCode = "QR-Code"
    case merchantOnline = "Online"

    // MARK: - Properties

    var displayName: String {
        rawValue
    }
}
