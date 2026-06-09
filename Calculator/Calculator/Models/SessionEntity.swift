//
//  SessionEntity.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import Foundation
import SwiftData

@Model
final class SessionEntity {
    @Attribute(.unique) var sessionId: String
    var addCount: Int
    var subtractCount: Int
    var multiplyCount: Int
    var divideCount: Int
    var lastUpdated: Date

    init(
        sessionId: String,
        addCount: Int = 0,
        subtractCount: Int = 0,
        multiplyCount: Int = 0,
        divideCount: Int = 0,
        lastUpdated: Date = Date()
    ) {
        self.sessionId = sessionId
        self.addCount = addCount
        self.subtractCount = subtractCount
        self.multiplyCount = multiplyCount
        self.divideCount = divideCount
        self.lastUpdated = lastUpdated
    }
}
