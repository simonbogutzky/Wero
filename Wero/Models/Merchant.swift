//
//  Merchant.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Merchant {
    // MARK: - Properties

    @Attribute(.unique) var id: String
    var name: String
    var category: String
    var address: String

    // MARK: - Initializers

    init(id: String = UUID().uuidString, name: String, category: String, address: String) {
        self.id = id
        self.name = name
        self.category = category
        self.address = address
    }
}
