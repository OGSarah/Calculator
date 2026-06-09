//
//  SessionService.swift
//  Calculator
//
//  Created by Sarah Clark on 3/1/25.
//

import Foundation

protocol SessionService {
    func fetchLastUpdated(for sessionId: String) -> Date?
    func saveSession(sessionId: String, operations: [String: Int], lastUpdated: Date?) -> SessionEntity
    func loadOperations(for sessionId: String) -> [String: Int]
    func fetchAllSessions() -> [SessionEntity]
    func postSessionDataToBackend(session: SessionData, completion: @escaping (Result<Void, Error>) -> Void)
#if DEBUG
    func deleteAllSessions()
#endif
}
