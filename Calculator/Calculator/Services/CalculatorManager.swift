//
//  CalculatorManager.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

// TODO: Delete this if not needed
/*import Foundation

class CalculatorManager: ObservableObject {
    private var operationCounts: [String: Int] = ["+": 0, "−": 0, "×": 0, "÷": 0]

    func incrementOperation(_ operation: String) {
        operationCounts[operation, default: 0] += 1
    }

    func sendSessionData(sessionId: String) {
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
            URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
                if let error = error {
                    print("Error sending data: \(error)")
                    return
                }
                print("Session data sent successfully")
            }.resume()
        } catch {
            print("Error encoding data: \(error)")
        }
    }
}
*/
