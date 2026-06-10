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
    /// Sends a session to the backend. Throws on failure; transport failures are
    /// queued for retry by the implementation before the error is rethrown.
    func postSessionDataToBackend(session: SessionData) async throws
    /// Retries any sessions that previously failed to reach the backend.
    func flushPendingSessions() async
#if DEBUG
    func deleteAllSessions()
#endif
}

/// Errors surfaced when syncing a session to the backend.
enum SessionSyncError: Error {
    case invalidResponse
    case serverError(statusCode: Int)
}
