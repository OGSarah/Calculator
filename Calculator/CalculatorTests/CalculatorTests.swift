//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Sarah Clark on 2/26/25.
//

import Testing
import Foundation
@testable import Calculator

struct CalculatorViewModelTests {

    // MARK: - Initial State
    @Test func initialStateIsZero() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        #expect(viewModel.display == "0")
        #expect(viewModel.calculationHistory.isEmpty)
    }

    @Test func sessionIdIsAssignedAndMatchesCurrentSession() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        #expect(!viewModel.sessionId.isEmpty)
        #expect(viewModel.getCurrentSessionData().sessionId == viewModel.sessionId)
    }

    @Test func newSessionStartsWithZeroedCounts() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        let session = viewModel.getCurrentSessionData()
        #expect(session.addCount == 0)
        #expect(session.subtractCount == 0)
        #expect(session.multiplyCount == 0)
        #expect(session.divideCount == 0)
    }

    // MARK: - Number Entry
    @Test func appendsSingleDigit() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("7")
        #expect(viewModel.display == "7")
    }

    @Test func appendsMultipleDigits() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("1")
        viewModel.handleButtonPress("2")
        viewModel.handleButtonPress("3")
        #expect(viewModel.display == "123")
    }

    @Test func leadingZeroIsReplacedByDigit() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("0")
        viewModel.handleButtonPress("5")
        #expect(viewModel.display == "5")
    }

    @Test func unrecognizedInputIsIgnored() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress(".")
        #expect(viewModel.display == "0")
    }

    // MARK: - Arithmetic
    @Test func addition() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("7")
        viewModel.handleButtonPress("+")
        viewModel.handleButtonPress("8")
        viewModel.handleButtonPress("=")
        #expect(viewModel.display == "15")
        #expect(viewModel.calculationHistory == "7 + 8 =")
    }

    @Test func subtraction() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("9")
        viewModel.handleButtonPress("−")
        viewModel.handleButtonPress("4")
        viewModel.handleButtonPress("=")
        #expect(viewModel.display == "5")
        #expect(viewModel.calculationHistory == "9 − 4 =")
    }

    @Test func subtractionCanProduceNegativeResult() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("4")
        viewModel.handleButtonPress("−")
        viewModel.handleButtonPress("9")
        viewModel.handleButtonPress("=")
        #expect(viewModel.display == "-5")
    }

    @Test func multiplication() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("6")
        viewModel.handleButtonPress("×")
        viewModel.handleButtonPress("7")
        viewModel.handleButtonPress("=")
        #expect(viewModel.display == "42")
    }

    @Test func division() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("8")
        viewModel.handleButtonPress("÷")
        viewModel.handleButtonPress("2")
        viewModel.handleButtonPress("=")
        #expect(viewModel.display == "4")
    }

    @Test func divisionByZeroReturnsZero() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("8")
        viewModel.handleButtonPress("÷")
        viewModel.handleButtonPress("0")
        viewModel.handleButtonPress("=")
        #expect(viewModel.display == "0")
    }

    @Test func pressingEqualsWithoutOperationDoesNothing() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("5")
        viewModel.handleButtonPress("=")
        #expect(viewModel.display == "5")
        #expect(viewModel.calculationHistory.isEmpty)
    }

    // MARK: - Operation Entry & History
    @Test func operationSetsHistoryAndResetsDisplay() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("7")
        viewModel.handleButtonPress("+")
        #expect(viewModel.calculationHistory == "7 +")
        #expect(viewModel.display == "0")
    }

    // MARK: - Clear
    @Test func clearResetsEverything() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("5")
        viewModel.handleButtonPress("+")
        viewModel.handleButtonPress("3")
        viewModel.handleButtonPress("AC")
        #expect(viewModel.display == "0")
        #expect(viewModel.calculationHistory.isEmpty)
    }

    // MARK: - Session Tracking
    @Test func additionIncrementsAddCountAndSaves() {
        let mock = MockSessionService()
        let viewModel = CalculatorViewModel(sessionService: mock)
        viewModel.handleButtonPress("2")
        viewModel.handleButtonPress("+")
        #expect(viewModel.getCurrentSessionData().addCount == 1)
        #expect(mock.saveCallCount == 1)
        #expect(mock.lastSavedOperations["+"] == 1)
        #expect(mock.lastSavedSessionId == viewModel.sessionId)
    }

    @Test func eachOperationIncrementsItsOwnCounter() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("1")
        viewModel.handleButtonPress("+")
        viewModel.handleButtonPress("2")
        viewModel.handleButtonPress("×")
        let session = viewModel.getCurrentSessionData()
        #expect(session.addCount == 1)
        #expect(session.multiplyCount == 1)
        #expect(session.subtractCount == 0)
        #expect(session.divideCount == 0)
    }

    @Test func subtractionIncrementsSubtractCount() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("9")
        viewModel.handleButtonPress("−")
        #expect(viewModel.getCurrentSessionData().subtractCount == 1)
    }

    @Test func divisionIncrementsDivideCount() {
        let viewModel = CalculatorViewModel(sessionService: MockSessionService())
        viewModel.handleButtonPress("9")
        viewModel.handleButtonPress("÷")
        #expect(viewModel.getCurrentSessionData().divideCount == 1)
    }

    // MARK: - Service Delegation
    @Test func getAllSessionsReturnsServiceResults() {
        let mock = MockSessionService()
        mock.sessionsToReturn = [
            mock.makeSessionEntity(sessionId: "abc", add: 3),
            mock.makeSessionEntity(sessionId: "def", subtract: 1)
        ]
        let viewModel = CalculatorViewModel(sessionService: mock)
        let sessions = viewModel.getAllSessions()
        #expect(sessions.count == 2)
        #expect(sessions.first?.sessionId == "abc")
    }

    @Test func postSessionDataDelegatesToService() {
        let mock = MockSessionService()
        let viewModel = CalculatorViewModel(sessionService: mock)
        viewModel.postSessionDataToBackend()
        #expect(mock.postCallCount == 1)
        #expect(mock.lastPostedSession?.sessionId == viewModel.sessionId)
    }
}
