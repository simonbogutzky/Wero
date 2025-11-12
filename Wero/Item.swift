//
//  Item.swift
//  Wero
//
//  Created by Dr. Simon Bogutzky on 12.11.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
