//
//  CalculatorViewModel.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import Foundation
import CoreData

class CalculatorViewModel: ObservableObject {
    @Published var display: String = "0"
    let sessionId: String
    private var currentNum: Double = 0
    private var previousNum: Double = 0
    private var operation: String = ""
    private var currentSession: SessionData
    private let coreDataManager = CoreDataManager.shared
    private let backendBaseURL = "http://localhost:3000"

    init() {
        if let savedId = UserDefaults.standard.string(forKey: "sessionId") {
            sessionId = savedId
            let operations = coreDataManager.loadOperations(for: sessionId)
            currentSession = SessionData(
                sessionId: sessionId,
                addCount: operations["+", default: 0],
                subtractCount: operations["−", default: 0],
                multiplyCount: operations["×", default: 0],
                divideCount: operations["÷", default: 0],
                lastUpdated: coreDataManager.fetchLastUpdated(for: sessionId) ?? Date()
            )
        } else {
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
        }
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
        currentNum = Double(display) ?? 0
    }

    private func setOperation(_ ope: String) {
        previousNum = currentNum
        operation = ope
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
        saveSessionData()
    }

    private func calculate() {
        let result: Double
        switch operation {
        case "+": result = previousNum + currentNum
        case "−": result = previousNum - currentNum
        case "×": result = previousNum * currentNum
        case "÷": result = currentNum != 0 ? previousNum / currentNum : 0
        default: return
        }
        display = String(result)
        currentNum = result
        operation = ""
    }

    private func clear() {
        display = "0"
        currentNum = 0
        previousNum = 0
        operation = ""
    }

    private func saveSessionData() {
        let operations = [
            "+": currentSession.addCount,
            "−": currentSession.subtractCount,
            "×": currentSession.multiplyCount,
            "÷": currentSession.divideCount
        ]
        coreDataManager.saveSession(
            sessionId: currentSession.sessionId,
            operations: operations,
            lastUpdated: currentSession.lastUpdated
        )

        guard let url = URL(string: "\(backendBaseURL)/api/session") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addBasicAuth(to: &request)

        do {
            let jsonData = try JSONEncoder().encode(currentSession)
            URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
                if let error = error {
                    print("Error sending data to backend: \(error)")
                    return
                }
                print("Session data sent to backend successfully")
            }.resume()
        } catch {
            print("Error encoding data: \(error)")
        }
    }

    func fetchAndSyncSessions(completion: @escaping ([SessionData]) -> Void) {
        guard let url = URL(string: "\(backendBaseURL)/api/sessions") else {
            completion([])
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addBasicAuth(to: &request)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // Handle string dates from backend

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching sessions: \(error)")
                completion([])
                return
            }

            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Invalid response from server")
                completion([])
                return
            }

            do {
                let sessions = try decoder.decode([SessionData].self, from: data)
                for session in sessions {
                    let operations = [
                        "+": session.addCount,
                        "−": session.subtractCount,
                        "×": session.multiplyCount,
                        "÷": session.divideCount
                    ]
                    self.coreDataManager.saveSession(
                        sessionId: session.sessionId,
                        operations: operations,
                        lastUpdated: session.lastUpdated
                    )
                }
                DispatchQueue.main.async {
                    completion(sessions)
                }
            } catch {
                print("Error decoding sessions: \(error)")
                completion([])
            }
        }.resume()
    }

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
