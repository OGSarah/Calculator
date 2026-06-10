//
//  SwiftDataManager.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import Foundation
import SwiftData

final class SwiftDataManager: SessionService {
    static let shared = SwiftDataManager()

    let modelContainer: ModelContainer
    private let context: ModelContext
    private let configuration: BackendConfiguration
    private let pendingStore: PendingSyncStore

    private init(
        configuration: BackendConfiguration = .current,
        pendingStore: PendingSyncStore = PendingSyncStore()
    ) {
        do {
            modelContainer = try ModelContainer(for: SessionEntity.self)
        } catch {
            fatalError("Unable to create ModelContainer: \(error)")
        }
        context = ModelContext(modelContainer)
        self.configuration = configuration
        self.pendingStore = pendingStore
    }

    func fetchLastUpdated(for sessionId: String) -> Date? {
        var descriptor = FetchDescriptor<SessionEntity>(
            predicate: #Predicate { $0.sessionId == sessionId }
        )
        descriptor.fetchLimit = 1

        do {
            return try context.fetch(descriptor).first?.lastUpdated
        } catch {
            print("Error fetching last updated: \(error)")
            return nil
        }
    }

    func saveSession(sessionId: String, operations: [String: Int], lastUpdated: Date?) -> SessionEntity {
        let descriptor = FetchDescriptor<SessionEntity>(
            predicate: #Predicate { $0.sessionId == sessionId }
        )

        let session: SessionEntity
        if let existingSession = try? context.fetch(descriptor).first {
            session = existingSession
        } else {
            session = SessionEntity(sessionId: sessionId)
            context.insert(session)
        }

        session.addCount = operations["+", default: 0]
        session.subtractCount = operations["−", default: 0]
        session.multiplyCount = operations["×", default: 0]
        session.divideCount = operations["÷", default: 0]
        session.lastUpdated = lastUpdated ?? Date()

        saveContext()
        return session
    }

    func loadOperations(for sessionId: String) -> [String: Int] {
        let descriptor = FetchDescriptor<SessionEntity>(
            predicate: #Predicate { $0.sessionId == sessionId }
        )

        if let session = try? context.fetch(descriptor).first {
            return [
                "+": session.addCount,
                "−": session.subtractCount,
                "×": session.multiplyCount,
                "÷": session.divideCount
            ]
        }
        return ["+": 0, "−": 0, "×": 0, "÷": 0]
    }

    func postSessionDataToBackend(session: SessionData) async throws {
        do {
            try await upload(session)
        } catch let error as URLError {
            // The backend was unreachable. Hold onto the data and retry it later
            // rather than dropping the session.
            print("Network error syncing session, queued for retry: \(error.localizedDescription)")
            pendingStore.enqueue(session)
            throw error
        }
        await persistSyncedSession(session)
    }

    func flushPendingSessions() async {
        for session in pendingStore.pendingSessions() {
            do {
                try await upload(session)
                pendingStore.remove(sessionId: session.sessionId)
                await persistSyncedSession(session)
            } catch is URLError {
                // Still offline. Leave everything queued and try again next time.
                break
            } catch {
                // Permanent failure (e.g. a rejected payload). Drop it so a single
                // bad entry can't block the rest of the queue forever.
                print("Dropping un-syncable session \(session.sessionId): \(error)")
                pendingStore.remove(sessionId: session.sessionId)
            }
        }
    }

    func fetchAllSessions() -> [SessionEntity] {
        let descriptor = FetchDescriptor<SessionEntity>(
            sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching sessions: \(error)")
            return []
        }
    }

#if DEBUG
    // For testing purposes only.
    func deleteAllSessions() {
        do {
            try context.delete(model: SessionEntity.self)
            try context.save()
            print("All sessions cleared from SwiftData")
        } catch {
            print("Error clearing sessions: \(error)")
        }
    }
#endif

    // MARK: - Private Functions

    /// Performs the POST. Throws `URLError` when the backend is unreachable and
    /// `SessionSyncError` when it responds with a non-success status.
    private func upload(_ session: SessionData) async throws {
        var request = URLRequest(url: configuration.sessionEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authHeader = configuration.basicAuthHeaderValue {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }

        let jsonData = try JSONEncoder().encode(session)
        let (_, response) = try await URLSession.shared.upload(for: request, from: jsonData)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SessionSyncError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw SessionSyncError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    /// Persists the synced session locally. Hops to the main actor because the
    /// `ModelContext` is created on, and must be used from, the main thread.
    private func persistSyncedSession(_ session: SessionData) async {
        let operations = [
            "+": session.addCount,
            "−": session.subtractCount,
            "×": session.multiplyCount,
            "÷": session.divideCount
        ]
        await MainActor.run {
            _ = self.saveSession(
                sessionId: session.sessionId,
                operations: operations,
                lastUpdated: session.lastUpdated
            )
        }
    }

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("Error saving context: \(nserror), \(nserror.userInfo)")
        }
    }
}
