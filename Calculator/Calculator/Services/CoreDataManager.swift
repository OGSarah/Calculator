//
//  CoreDataManager.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import CoreData

class CoreDataManager: SessionService {
    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CalculatorDataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func fetchLastUpdated(for sessionId: String) -> Date? {
        let fetchRequest: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId)
        fetchRequest.fetchLimit = 1

        do {
            if let session = try context.fetch(fetchRequest).first {
                return session.lastUpdated
            }
        } catch {
            print("Error fetching last updated: \(error)")
        }
        return nil
    }

    func saveSessionToCoreData(sessionId: String, operations: [String: Int], lastUpdated: Date?, postedToBackend: Date? = nil) -> SessionEntity {
        let fetchRequest: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId)

        do {
            let results = try context.fetch(fetchRequest)
            let session: SessionEntity

            if let existingSession = results.first {
                session = existingSession
            } else {
                session = SessionEntity(context: context)
                session.sessionId = sessionId
            }

            session.addCount = Int32(operations["+", default: 0])
            session.subtractCount = Int32(operations["−", default: 0])
            session.multiplyCount = Int32(operations["×", default: 0])
            session.divideCount = Int32(operations["÷", default: 0])
            session.lastUpdated = lastUpdated ?? Date()

            saveContext()
            return session
        } catch {
            print("Error saving session: \(error)")
            let session = SessionEntity(context: context)
            session.sessionId = sessionId
            return session
        }
    }

    func loadOperations(for sessionId: String) -> [String: Int] {
        let fetchRequest: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sessionId == %@", sessionId)

        do {
            if let session = try context.fetch(fetchRequest).first {
                return [
                    "+": Int(session.addCount),
                    "−": Int(session.subtractCount),
                    "×": Int(session.multiplyCount),
                    "÷": Int(session.divideCount)
                ]
            }
        } catch {
            print("Error loading session: \(error)")
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
                    // On success, update Core Data with the posting time
                    let postingTime = Date()
                    let operations = [
                        "+": session.addCount,
                        "−": session.subtractCount,
                        "×": session.multiplyCount,
                        "÷": session.divideCount
                    ]
                    let formatter = ISO8601DateFormatter()
                    let lastUpdatedDate = formatter.date(from: session.lastUpdated) ?? postingTime
                    _ = self.saveSessionToCoreData(
                        sessionId: session.sessionId,
                        operations: operations,
                        lastUpdated: lastUpdatedDate,
                        postedToBackend: postingTime
                    )
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

    func fetchAllSessionsFromCoreData() -> [SessionEntity] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "lastUpdated", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching sessions: \(error)")
            return []
        }
    }

#if DEBUG
    // For testing purposes only.
    func deleteAllSessionsInCoreData() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = SessionEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("All sessions cleared from Core Data")
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
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Error saving context: \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
