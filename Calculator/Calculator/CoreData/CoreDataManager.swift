//
//  CoreDataManager.swift
//  Calculator
//
//  Created by Sarah Clark on 2/26/25.
//

import CoreData

class CoreDataManager {
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
        let context = persistentContainer.viewContext
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

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Error saving context: \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func saveSession(sessionId: String, operations: [String: Int], lastUpdated: Date? = nil) -> SessionEntity {
        let context = persistentContainer.viewContext
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
        let context = persistentContainer.viewContext
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

    func fetchAllSessions() -> [SessionEntity] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching sessions: \(error)")
            return []
        }
    }

}
