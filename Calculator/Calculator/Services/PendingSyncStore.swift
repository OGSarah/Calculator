//
//  PendingSyncStore.swift
//  Calculator
//
//  A small persistent queue of sessions that failed to reach the backend.
//  Entries are written to disk as JSON so they survive relaunches and can be
//  retried the next time a sync is attempted. The queue is keyed by sessionId,
//  so a newer snapshot of a session replaces any earlier one already queued.
//

import Foundation

final class PendingSyncStore {
    private let fileURL: URL
    // Serializes reads/writes so concurrent sync attempts don't corrupt the file.
    private let accessQueue = DispatchQueue(label: "com.calculator.PendingSyncStore")

    init(fileName: String = "pending-sessions.json", directory: URL? = nil) {
        let baseDirectory = directory
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        try? FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        fileURL = baseDirectory.appendingPathComponent(fileName)
    }

    /// Adds a session to the queue, replacing any existing entry with the same id.
    func enqueue(_ session: SessionData) {
        accessQueue.sync {
            var sessions = read()
            sessions.removeAll { $0.sessionId == session.sessionId }
            sessions.append(session)
            write(sessions)
        }
    }

    /// Removes the queued entry for a session once it has synced successfully.
    func remove(sessionId: String) {
        accessQueue.sync {
            var sessions = read()
            sessions.removeAll { $0.sessionId == sessionId }
            write(sessions)
        }
    }

    /// The sessions currently waiting to be retried.
    func pendingSessions() -> [SessionData] {
        accessQueue.sync { read() }
    }

    // MARK: - Private (callers must already hold `accessQueue`)
    private func read() -> [SessionData] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([SessionData].self, from: data)) ?? []
    }

    private func write(_ sessions: [SessionData]) {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
