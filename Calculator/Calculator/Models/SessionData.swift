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
    let lastUpdated: Date

    var id: String {
        sessionId
    }

    enum CodingKeys: String, CodingKey {
        case sessionId, addCount, subtractCount, multiplyCount, divideCount, lastUpdated
    }

    init(sessionId: String, addCount: Int, subtractCount: Int, multiplyCount: Int, divideCount: Int, lastUpdated: Date) {
        self.sessionId = sessionId
        self.addCount = addCount
        self.subtractCount = subtractCount
        self.multiplyCount = multiplyCount
        self.divideCount = divideCount
        self.lastUpdated = lastUpdated
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        addCount = try container.decode(Int.self, forKey: .addCount)
        subtractCount = try container.decode(Int.self, forKey: .subtractCount)
        multiplyCount = try container.decode(Int.self, forKey: .multiplyCount)
        divideCount = try container.decode(Int.self, forKey: .divideCount)

        let dateString = try container.decode(String.self, forKey: .lastUpdated)
        if let date = ISO8601DateFormatter().date(from: dateString) {
            lastUpdated = date
        } else {
            lastUpdated = Date()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(addCount, forKey: .addCount)
        try container.encode(subtractCount, forKey: .subtractCount)
        try container.encode(multiplyCount, forKey: .multiplyCount)
        try container.encode(divideCount, forKey: .divideCount)
        try container.encode(ISO8601DateFormatter().string(from: lastUpdated), forKey: .lastUpdated)
    }

}
