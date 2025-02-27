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
    private var operationCounts: [String: Int] = ["+": 0, "−": 0, "×": 0, "÷": 0]
    private let coreDataManager = CoreDataManager.shared
    private let backendBaseURL = "http://localhost:3000" // Adjust for physical device IP if needed

    init() {
        if let savedId = UserDefaults.standard.string(forKey: "sessionId") {
            sessionId = savedId
        } else {
            sessionId = UUID().uuidString
            UserDefaults.standard.set(sessionId, forKey: "sessionId")
        }
        operationCounts = coreDataManager.loadOperations(for: sessionId)
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
        operationCounts[ope, default: 0] += 1
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
        coreDataManager.saveSession(sessionId: sessionId, operations: operationCounts)

        guard let url = URL(string: "\(backendBaseURL)/api/session") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addBasicAuth(to: &request)

        let data = SessionData(sessionId: sessionId, operations: operationCounts)

        do {
            let jsonData = try JSONEncoder().encode(data)
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
                let sessions = try JSONDecoder().decode([SessionData].self, from: data)
                // Sync with CoreData
                for session in sessions {
                    self.coreDataManager.saveSession(sessionId: session.sessionId, operations: session.operations)
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

    func getCurrentOperationCounts() -> [String: Int] {
        return operationCounts
    }
}
