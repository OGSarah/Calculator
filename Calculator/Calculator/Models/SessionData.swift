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
        case sessionId
        case addCount
        case subtractCount
        case multiplyCount
        case divideCount
        case lastUpdated
    }

}
