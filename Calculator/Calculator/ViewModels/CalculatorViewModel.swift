//
//  CalculatorViewModel.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import Foundation

class CalculatorViewModel: ObservableObject {
    @Published var display: String = "0"
    let sessionId: String
    private var currentNum: Double = 0
    private var previousNum: Double = 0
    private var operation: String = ""
    private var operationCounts: [String: Int] = ["+": 0, "-": 0, "*": 0, "/": 0]

    init() {
        if let savedId = UserDefaults.standard.string(forKey: "sessionId") {
            sessionId = savedId
        } else {
            sessionId = UUID().uuidString
            UserDefaults.standard.set(sessionId, forKey: "sessionId")
        }
    }

    func handleButtonPress(_ value: String) {
        switch value {
            case "0"..."9":
                appendNumber(value)
            case "+", "-", "*", "/":
                setOperation(value)
            case "=":
                calculate()
            case "C":
                clear()
            default:
                break
        }
    }

    private func appendNumber(_ num: String) {
        display = (display == "0" ? "" : display) + num
        currentNum = Double(display) ?? 0
    }

    private func setOperation(_ op: String) {
        previousNum = currentNum
        operation = op
        display = "0"
        operationCounts[op, default: 0] += 1
        saveSessionData()
    }

    private func calculate() {
        let result: Double
        switch operation {
            case "+": result = previousNum + currentNum
            case "-": result = previousNum - currentNum
            case "*": result = previousNum * currentNum
            case "/": result = currentNum != 0 ? previousNum / currentNum : 0
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
        guard let url = URL(string: "http://localhost:3000/api/session") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let data = SessionData(
            sessionId: sessionId,
            operations: operationCounts
        )

        do {
            let jsonData = try JSONEncoder().encode(data)
            URLSession.shared.uploadTask(with: request, from: jsonData).resume()
        } catch {
            print("Error encoding data: \(error)")
        }
    }

}
