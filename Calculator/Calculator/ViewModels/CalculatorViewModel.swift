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
    private let coreDataManager = CoreDataManager.shared
    private let backendBaseURL = "http://localhost:3000"

    init() {

#if DEBUG
            // Only needing for testing.
            // coreDataManager.deleteAllSessionsInCoreData()
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
        // Parse lastUpdated back to Date for Core Data
        let dateFormatter = ISO8601DateFormatter()
        let lastUpdatedDate = dateFormatter.date(from: currentSession.lastUpdated) ?? Date()
        coreDataManager.saveSession(
            sessionId: currentSession.sessionId,
            operations: operations,
            lastUpdated: lastUpdatedDate
        )
    }

    func syncSessionDataToBackend() {
        guard let url = URL(string: "\(backendBaseURL)/api/session") else {
            print("Invalid URL: \(backendBaseURL)/api/session")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addBasicAuth(to: &request)

        do {
            let jsonData = try JSONEncoder().encode(currentSession)
            print("Sending session data: \(String(data: jsonData, encoding: .utf8) ?? "Unable to decode")")
            URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("Backend response status: \(httpResponse.statusCode)")
                    if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                        print("Backend response body: \(responseString)")
                    }
                }
            }.resume()
        } catch {
            print("Error encoding session data: \(error)")
        }
    }

    // In a dev or production environment, there would not be a hardcoded username and password.
    private func addBasicAuth(to request: inout URLRequest) {
        let authString = "admin:calculator123"
        if let authData = authString.data(using: .utf8) {
            let base64Auth = authData.base64EncodedString()
            request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        }
    }

    func getAllSessions() -> [SessionEntity] {
        return coreDataManager.fetchAllSessions()
    }

    func getCurrentSessionData() -> SessionData {
        return currentSession
    }
}
