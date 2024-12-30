//
//  KeyPathCheck.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/12/2024.
//

import Testing

/// A struct to check if two models are equal at their key paths
/// - Note: `@unchecked` is included as its use is only for tests, and will only call `equate` once the model is updated
struct KeyPathCheck<DBModelType, APIModelType>: @unchecked Sendable {
    let dbName: String
    let apiName: String
    let equate: ((DBModelType, APIModelType) -> (Bool))
    
    init<T: Equatable>(dbKeyPath: KeyPath<DBModelType, T>, apiKeyPath: KeyPath<APIModelType, T>) throws {
        dbName = try #require(String(describing: dbKeyPath).components(separatedBy: ".").last)
        apiName = try #require(String(describing: apiKeyPath).components(separatedBy: ".").last)
        equate = { dbModel, apiModel in
            dbModel[keyPath: dbKeyPath] == apiModel[keyPath: apiKeyPath]
        }
    }
}
