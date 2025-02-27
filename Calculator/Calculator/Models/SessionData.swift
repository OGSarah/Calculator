//
//  SessionData.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

struct SessionData: Codable, Identifiable {
    let sessionId: String
    let operations: [String: Int]

    var id: String {
        sessionId
    }

}
