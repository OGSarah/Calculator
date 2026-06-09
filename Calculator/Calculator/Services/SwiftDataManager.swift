//
//  SwiftDataManager.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import Foundation
import SwiftData

final class SwiftDataManager: SessionService {
    static let shared = SwiftDataManager()

    let modelContainer: ModelContainer
    private let context: ModelContext

    private init() {
        do {
            modelContainer = try ModelContainer(for: SessionEntity.self)
        } catch {
            fatalError("Unable to create ModelContainer: \(error)")
        }
        context = ModelContext(modelContainer)
    }

    func fetchLastUpdated(for sessionId: String) -> Date? {
        var descriptor = FetchDescriptor<SessionEntity>(
            predicate: #Predicate { $0.sessionId == sessionId }
        )
        descriptor.fetchLimit = 1

        do {
            return try context.fetch(descriptor).first?.lastUpdated
        } catch {
            print("Error fetching last updated: \(error)")
            return nil
        }
    }

    func saveSession(sessionId: String, operations: [String: Int], lastUpdated: Date?) -> SessionEntity {
        let descriptor = FetchDescriptor<SessionEntity>(
            predicate: #Predicate { $0.sessionId == sessionId }
        )

        let session: SessionEntity
        if let existingSession = try? context.fetch(descriptor).first {
            session = existingSession
        } else {
            session = SessionEntity(sessionId: sessionId)
            context.insert(session)
        }

        session.addCount = operations["+", default: 0]
        session.subtractCount = operations["−", default: 0]
        session.multiplyCount = operations["×", default: 0]
        session.divideCount = operations["÷", default: 0]
        session.lastUpdated = lastUpdated ?? Date()

        saveContext()
        return session
    }

    func loadOperations(for sessionId: String) -> [String: Int] {
        let descriptor = FetchDescriptor<SessionEntity>(
            predicate: #Predicate { $0.sessionId == sessionId }
        )

        if let session = try? context.fetch(descriptor).first {
            return [
                "+": session.addCount,
                "−": session.subtractCount,
                "×": session.multiplyCount,
                "÷": session.divideCount
            ]
        }
        return ["+": 0, "−": 0, "×": 0, "÷": 0]
    }

    func postSessionDataToBackend(session: SessionData, completion: @escaping (Result<Void, any Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/api/session") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addBasicAuth(to: &request)

        do {
            let jsonData = try JSONEncoder().encode(session)
            print("Sending session data: \(String(data: jsonData, encoding: .utf8) ?? "Unable to decode")")
            URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {

                    let operations = [
                        "+": session.addCount,
                        "−": session.subtractCount,
                        "×": session.multiplyCount,
                        "÷": session.divideCount
                    ]

                    // Persist back on the main queue, where the context is used.
                    DispatchQueue.main.async {
                        _ = self.saveSession(
                            sessionId: session.sessionId,
                            operations: operations,
                            lastUpdated: session.lastUpdated
                        )
                    }
                    print("Backend response status: \(httpResponse.statusCode)")
                    if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                        print("Backend response body: \(responseString)")
                    }
                    completion(.success(()))
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("Backend response status: \(httpResponse.statusCode)")
                    if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                        print("Backend response body: \(responseString)")
                    }
                }
            }.resume()
        } catch {
            print("Error encoding session data: \(error)")
            completion(.failure(error))
        }
    }

    func fetchAllSessions() -> [SessionEntity] {
        let descriptor = FetchDescriptor<SessionEntity>(
            sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching sessions: \(error)")
            return []
        }
    }

#if DEBUG
    // For testing purposes only.
    func deleteAllSessions() {
        do {
            try context.delete(model: SessionEntity.self)
            try context.save()
            print("All sessions cleared from SwiftData")
        } catch {
            print("Error clearing sessions: \(error)")
        }
    }
#endif

    // MARK: - Private Functions
    private func addBasicAuth(to request: inout URLRequest) {
        // In a dev or production environment, there would not be a hardcoded username and password.
        let authString = "admin:calculator123"
        if let authData = authString.data(using: .utf8) {
            let base64Auth = authData.base64EncodedString()
            request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        }
    }

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("Error saving context: \(nserror), \(nserror.userInfo)")
        }
    }
}
