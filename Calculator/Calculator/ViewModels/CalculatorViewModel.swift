//
//  CalculatorViewModel.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import CoreData
import Foundation
import SwiftUI

class CalculatorViewModel: ObservableObject {
    @Published var display: String = "0"
    @Published var calculationHistory: String = ""
    let sessionId: String
    private var currentNum: Int = 0
    private var previousNum: Int = 0
    private var operation: String = ""
    private var currentSession: SessionData
    private let sessionService: SessionService

    init(sessionService: SessionService = CoreDataManager.shared) {
        self.sessionService = sessionService
#if DEBUG
            // sessionService.deleteAllSessionsInCoreData() // Uncomment for testing
#endif
            // Always create a new session ID on app launch per the project requirements.
            sessionId = UUID().uuidString
            UserDefaults.standard.set(sessionId, forKey: "sessionId")
            currentSession = SessionData(
                sessionId: sessionId,
                addCount: 0,
                subtractCount: 0,
                multiplyCount: 0,
                divideCount: 0,
                lastUpdated: Date()
            )
            // Clear any previous UserDefaults value if it exists.
            UserDefaults.standard.removeObject(forKey: "sessionId")
    }

    func handleButtonPress(_ value: String) {
        switch value {
        case "0"..."9":
            appendNumber(value)
        case "+", "−", "×", "÷":
            setOperation(value)
        case "=":
            calculate()
        case "AC":
            clear()
        default:
            break
        }
    }

    func getAllSessions() -> [SessionEntity] {
        return sessionService.fetchAllSessionsFromCoreData()
    }

    func getCurrentSessionData() -> SessionData {
        return currentSession
    }

    func postSessionDataToBackend() {
        sessionService.postSessionDataToBackend(session: currentSession) { result in
            switch result {
            case .success:
                print("Session data posted to backend successfully")

                // Update currentSession with the posted time
                self.currentSession = SessionData(
                    sessionId: self.currentSession.sessionId,
                    addCount: self.currentSession.addCount,
                    subtractCount: self.currentSession.subtractCount,
                    multiplyCount: self.currentSession.multiplyCount,
                    divideCount: self.currentSession.divideCount,
                    lastUpdated: self.currentSession.lastUpdated
                )
            case .failure(let error):
                print("Failed to post session data: \(error)")
            }
        }
    }

    // MARK: - Private Functions
    private func appendNumber(_ num: String) {
        display = (display == "0" ? "" : display) + num
        currentNum = Int(display) ?? 0
    }

    private func setOperation(_ ope: String) {
        previousNum = currentNum
        operation = ope
        calculationHistory = "\(previousNum) \(ope)"
        display = "0"
        switch ope {
        case "+":
            currentSession = SessionData(
                sessionId: currentSession.sessionId,
                addCount: currentSession.addCount + 1,
                subtractCount: currentSession.subtractCount,
                multiplyCount: currentSession.multiplyCount,
                divideCount: currentSession.divideCount,
                lastUpdated: Date()
            )
        case "−":
            currentSession = SessionData(
                sessionId: currentSession.sessionId,
                addCount: currentSession.addCount,
                subtractCount: currentSession.subtractCount + 1,
                multiplyCount: currentSession.multiplyCount,
                divideCount: currentSession.divideCount,
                lastUpdated: Date()
            )
        case "×":
            currentSession = SessionData(
                sessionId: currentSession.sessionId,
                addCount: currentSession.addCount,
                subtractCount: currentSession.subtractCount,
                multiplyCount: currentSession.multiplyCount + 1,
                divideCount: currentSession.divideCount,
                lastUpdated: Date()
            )
        case "÷":
            currentSession = SessionData(
                sessionId: currentSession.sessionId,
                addCount: currentSession.addCount,
                subtractCount: currentSession.subtractCount,
                multiplyCount: currentSession.multiplyCount,
                divideCount: currentSession.divideCount + 1,
                lastUpdated: Date()
            )
        default:
            break
        }
        saveSessionDataToCoreData()
    }

    private func calculate() {
        let result: Int
        switch operation {
        case "+": result = previousNum + currentNum
        case "−": result = previousNum - currentNum
        case "×": result = previousNum * currentNum
        case "÷": result = currentNum != 0 ? previousNum / currentNum : 0
        default: return
        }

        // Update history with full calculation before showing result.
        calculationHistory = "\(previousNum) \(operation) \(currentNum) ="
        display = String(result)
        currentNum = result
        operation = ""
    }

    private func clear() {
        display = "0"
        calculationHistory = ""
        currentNum = 0
        previousNum = 0
        operation = ""
    }

    private func saveSessionDataToCoreData() {
        let operations = [
            "+": currentSession.addCount,
            "−": currentSession.subtractCount,
            "×": currentSession.multiplyCount,
            "÷": currentSession.divideCount
        ]
        _ = sessionService.saveSessionToCoreData(
            sessionId: currentSession.sessionId,
            operations: operations,
            lastUpdated: currentSession.lastUpdated
        )
    }

}
