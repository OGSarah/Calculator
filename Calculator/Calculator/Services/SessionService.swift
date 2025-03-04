//
//  SessionService.swift
//  Calculator
//
//  Created by Sarah Clark on 3/1/25.
//

import CoreData

protocol SessionService {
    func fetchLastUpdated(for sessionId: String) -> Date?
    func saveSessionToCoreData(sessionId: String, operations: [String: Int], lastUpdated: Date?) -> SessionEntity
    func loadOperations(for sessionId: String) -> [String: Int]
    func fetchAllSessionsFromCoreData() -> [SessionEntity]
    func postSessionDataToBackend(session: SessionData, completion: @escaping (Result<Void, Error>) -> Void)
#if DEBUG
    func deleteAllSessionsInCoreData()
#endif
}
