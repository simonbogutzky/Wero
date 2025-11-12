//
//  Contact.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Contact {
    // MARK: - Properties

    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var phoneNumber: String

    // MARK: - Initializers

    init(id: String = UUID().uuidString, name: String, email: String, phoneNumber: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
    }
}
