//
//  SessionDataTests.swift
//  CalculatorTests
//
//  Tests for SessionData's custom Codable conformance and identity.
//

import Testing
import Foundation
@testable import Calculator

struct SessionDataTests {

    private let fixedDate = ISO8601DateFormatter().date(from: "2026-06-09T12:00:00Z")!

    @Test func idMatchesSessionId() {
        let session = SessionData(
            sessionId: "xyz",
            addCount: 0,
            subtractCount: 0,
            multiplyCount: 0,
            divideCount: 0,
            lastUpdated: fixedDate
        )
        #expect(session.id == "xyz")
    }

    @Test func encodeDecodeRoundTripPreservesValues() throws {
        let session = SessionData(
            sessionId: "s1",
            addCount: 1,
            subtractCount: 2,
            multiplyCount: 3,
            divideCount: 4,
            lastUpdated: fixedDate
        )

        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(SessionData.self, from: data)

        #expect(decoded.sessionId == "s1")
        #expect(decoded.addCount == 1)
        #expect(decoded.subtractCount == 2)
        #expect(decoded.multiplyCount == 3)
        #expect(decoded.divideCount == 4)
        #expect(decoded.lastUpdated == fixedDate)
    }

    @Test func encodesDateAsISO8601String() throws {
        let session = SessionData(
            sessionId: "s1",
            addCount: 0,
            subtractCount: 0,
            multiplyCount: 0,
            divideCount: 0,
            lastUpdated: fixedDate
        )

        let data = try JSONEncoder().encode(session)
        let json = try #require(String(data: data, encoding: .utf8))
        #expect(json.contains("2026-06-09T12:00:00Z"))
    }

    @Test func decodingInvalidDateFallsBackToNow() throws {
        let json = """
        {"sessionId":"s","addCount":0,"subtractCount":0,"multiplyCount":0,"divideCount":0,"lastUpdated":"not-a-date"}
        """
        let decoded = try JSONDecoder().decode(SessionData.self, from: Data(json.utf8))

        #expect(decoded.sessionId == "s")
        // An unparseable date falls back to "now", so it should be very recent.
        #expect(abs(decoded.lastUpdated.timeIntervalSinceNow) < 5)
    }
}
