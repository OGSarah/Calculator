//
//  SessionData.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import Foundation

struct SessionData: Codable, Identifiable {
    let sessionId: String
    let addCount: Int
    let subtractCount: Int
    let multiplyCount: Int
    let divideCount: Int
    let lastUpdated: String
    let postedToBackend: String?

    var id: String {
        sessionId
    }

    enum CodingKeys: String, CodingKey {
        case sessionId, addCount, subtractCount, multiplyCount, divideCount, lastUpdated, postedToBackend
    }

    init(sessionId: String, addCount: Int, subtractCount: Int, multiplyCount: Int, divideCount: Int, lastUpdated: Date, postedToBackend: Date? = nil) {
        self.sessionId = sessionId
        self.addCount = addCount
        self.subtractCount = subtractCount
        self.multiplyCount = multiplyCount
        self.divideCount = divideCount
        self.lastUpdated = ISO8601DateFormatter().string(from: lastUpdated)
        self.postedToBackend = postedToBackend.map { ISO8601DateFormatter().string(from: $0) }
    }

}
