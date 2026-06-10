//
//  PendingSyncStoreTests.swift
//  CalculatorTests
//
//  Verifies the offline retry queue persists, dedupes, and removes entries.
//

import Testing
import Foundation
@testable import Calculator

struct PendingSyncStoreTests {

    /// Each test gets its own throwaway directory so runs don't interfere.
    private func makeStore() -> (PendingSyncStore, URL) {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PendingSyncStoreTests-\(UUID().uuidString)")
        let store = PendingSyncStore(fileName: "pending.json", directory: directory)
        return (store, directory)
    }

    private func makeSession(id: String, add: Int = 0) -> SessionData {
        SessionData(
            sessionId: id,
            addCount: add,
            subtractCount: 0,
            multiplyCount: 0,
            divideCount: 0,
            lastUpdated: Date(timeIntervalSince1970: 0)
        )
    }

    @Test func enqueueThenReadReturnsSession() {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.enqueue(makeSession(id: "a", add: 3))
        let pending = store.pendingSessions()

        #expect(pending.count == 1)
        #expect(pending.first?.sessionId == "a")
        #expect(pending.first?.addCount == 3)
    }

    @Test func enqueueSameIdReplacesEarlierEntry() {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.enqueue(makeSession(id: "a", add: 1))
        store.enqueue(makeSession(id: "a", add: 9))

        let pending = store.pendingSessions()
        #expect(pending.count == 1)
        #expect(pending.first?.addCount == 9)
    }

    @Test func removeDeletesQueuedEntry() {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.enqueue(makeSession(id: "a"))
        store.enqueue(makeSession(id: "b"))
        store.remove(sessionId: "a")

        let pending = store.pendingSessions()
        #expect(pending.count == 1)
        #expect(pending.first?.sessionId == "b")
    }

    @Test func queuePersistsAcrossStoreInstances() {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.enqueue(makeSession(id: "persisted"))

        // A fresh store pointed at the same file should see the queued entry,
        // mirroring what happens across app launches.
        let reopened = PendingSyncStore(fileName: "pending.json", directory: directory)
        #expect(reopened.pendingSessions().first?.sessionId == "persisted")
    }
}
