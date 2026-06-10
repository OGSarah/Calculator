//
//  MockSessionService.swift
//  CalculatorTests
//
//  A test double for SessionService that records interactions and avoids
//  touching the real SwiftData store or the network. SwiftData @Model
//  instances can be created directly, so it vends real SessionEntity
//  objects without needing a ModelContext.
//

import Foundation
@testable import Calculator

final class MockSessionService: SessionService {

    // MARK: - Recorded Interactions
    private(set) var saveCallCount = 0
    private(set) var lastSavedSessionId: String?
    private(set) var lastSavedOperations: [String: Int] = [:]
    private(set) var lastSavedDate: Date?
    private(set) var postCallCount = 0
    private(set) var lastPostedSession: SessionData?
    private(set) var flushCallCount = 0
    private(set) var deleteCallCount = 0

    // MARK: - Configurable Behavior
    var sessionsToReturn: [SessionEntity] = []
    /// When set, `postSessionDataToBackend` throws this instead of succeeding.
    var postError: Error?

    private var storedOperations: [String: [String: Int]] = [:]
    private var storedDates: [String: Date] = [:]

    // MARK: - SessionService
    func fetchLastUpdated(for sessionId: String) -> Date? {
        storedDates[sessionId]
    }

    func saveSession(sessionId: String, operations: [String: Int], lastUpdated: Date?) -> SessionEntity {
        saveCallCount += 1
        lastSavedSessionId = sessionId
        lastSavedOperations = operations
        lastSavedDate = lastUpdated
        storedOperations[sessionId] = operations
        if let lastUpdated {
            storedDates[sessionId] = lastUpdated
        }

        return makeSessionEntity(
            sessionId: sessionId,
            add: operations["+", default: 0],
            subtract: operations["−", default: 0],
            multiply: operations["×", default: 0],
            divide: operations["÷", default: 0],
            lastUpdated: lastUpdated ?? Date()
        )
    }

    func loadOperations(for sessionId: String) -> [String: Int] {
        storedOperations[sessionId] ?? ["+": 0, "−": 0, "×": 0, "÷": 0]
    }

    func fetchAllSessions() -> [SessionEntity] {
        sessionsToReturn
    }

    func postSessionDataToBackend(session: SessionData) async throws {
        postCallCount += 1
        lastPostedSession = session
        if let postError {
            throw postError
        }
    }

    func flushPendingSessions() async {
        flushCallCount += 1
    }

#if DEBUG
    func deleteAllSessions() {
        deleteCallCount += 1
    }
#endif

    // MARK: - Test Helpers
    func makeSessionEntity(
        sessionId: String,
        add: Int = 0,
        subtract: Int = 0,
        multiply: Int = 0,
        divide: Int = 0,
        lastUpdated: Date = Date()
    ) -> SessionEntity {
        SessionEntity(
            sessionId: sessionId,
            addCount: add,
            subtractCount: subtract,
            multiplyCount: multiply,
            divideCount: divide,
            lastUpdated: lastUpdated
        )
    }
}
