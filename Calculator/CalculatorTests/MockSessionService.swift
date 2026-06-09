//
//  MockSessionService.swift
//  CalculatorTests
//
//  A test double for SessionService that records interactions and avoids
//  touching the real Core Data store or the network. It uses a lightweight
//  in-memory Core Data stack so it can vend real SessionEntity instances
//  where the protocol requires them.
//

import CoreData
@testable import Calculator

final class MockSessionService: SessionService {

    // MARK: - Recorded Interactions
    private(set) var saveCallCount = 0
    private(set) var lastSavedSessionId: String?
    private(set) var lastSavedOperations: [String: Int] = [:]
    private(set) var lastSavedDate: Date?
    private(set) var postCallCount = 0
    private(set) var lastPostedSession: SessionData?
    private(set) var deleteCallCount = 0

    // MARK: - Configurable Behavior
    var sessionsToReturn: [SessionEntity] = []
    var postResult: Result<Void, Error> = .success(())

    private var storedOperations: [String: [String: Int]] = [:]
    private var storedDates: [String: Date] = [:]

    // In-memory Core Data context used only to create SessionEntity objects.
    private lazy var context: NSManagedObjectContext = {
        let bundle = Bundle(for: CoreDataManager.self)
        guard let model = NSManagedObjectModel.mergedModel(from: [bundle]) else {
            fatalError("Unable to load the CalculatorDataModel managed object model for testing.")
        }
        let container = NSPersistentContainer(name: "CalculatorDataModel", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            precondition(error == nil, "Failed to load in-memory store: \(String(describing: error))")
        }
        return container.viewContext
    }()

    // MARK: - SessionService
    func fetchLastUpdated(for sessionId: String) -> Date? {
        storedDates[sessionId]
    }

    func saveSessionToCoreData(sessionId: String, operations: [String: Int], lastUpdated: Date?) -> SessionEntity {
        saveCallCount += 1
        lastSavedSessionId = sessionId
        lastSavedOperations = operations
        lastSavedDate = lastUpdated
        storedOperations[sessionId] = operations
        if let lastUpdated {
            storedDates[sessionId] = lastUpdated
        }

        return makeSessionEntity(
            sessionId: sessionId,
            add: operations["+", default: 0],
            subtract: operations["−", default: 0],
            multiply: operations["×", default: 0],
            divide: operations["÷", default: 0],
            lastUpdated: lastUpdated ?? Date()
        )
    }

    func loadOperations(for sessionId: String) -> [String: Int] {
        storedOperations[sessionId] ?? ["+": 0, "−": 0, "×": 0, "÷": 0]
    }

    func fetchAllSessionsFromCoreData() -> [SessionEntity] {
        sessionsToReturn
    }

    func postSessionDataToBackend(session: SessionData, completion: @escaping (Result<Void, Error>) -> Void) {
        postCallCount += 1
        lastPostedSession = session
        completion(postResult)
    }

#if DEBUG
    func deleteAllSessionsInCoreData() {
        deleteCallCount += 1
    }
#endif

    // MARK: - Test Helpers
    func makeSessionEntity(
        sessionId: String,
        add: Int = 0,
        subtract: Int = 0,
        multiply: Int = 0,
        divide: Int = 0,
        lastUpdated: Date = Date()
    ) -> SessionEntity {
        let entity = SessionEntity(context: context)
        entity.sessionId = sessionId
        entity.addCount = Int32(add)
        entity.subtractCount = Int32(subtract)
        entity.multiplyCount = Int32(multiply)
        entity.divideCount = Int32(divide)
        entity.lastUpdated = lastUpdated
        return entity
    }
}
