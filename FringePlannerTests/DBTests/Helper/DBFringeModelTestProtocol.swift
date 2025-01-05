//
//  DBFringeModelTestProtocol.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/12/2024.
//

import SwiftData
import Testing
@testable import FringePlanner

protocol DBFringeModelTestProtocol {
    associatedtype DBModelType: DBFringeModelTestSupport
}

// MARK: Test

extension DBFringeModelTestProtocol {
    /// Test that the update method copies all of the fields from the API model to the DB model
    func autoTestUpdateCopiesAllFields() throws {
        // Store the variables to avoid re-generating them
        let dbModel = DBModelType.dbModel
        let keyPaths = try DBModelType.keyPaths
        let apiModel = DBModelType.apiModel
        
        // Verify that all of the fields in both models are different
        for keyPath in keyPaths {
            try #require(!keyPath.equate(dbModel, apiModel), "\(DBModelType.self).\(keyPath.dbName) & \(DBModelType.APIFringeModelType.self).\(keyPath.apiName) should not be equal")
        }
        // Update the model
        dbModel.update(from: apiModel)
        
        // Test that all of the fields now match
        for keyPath in keyPaths {
            #expect(keyPath.equate(dbModel, apiModel), "\(DBModelType.self).\(keyPath.dbName) & \(DBModelType.APIFringeModelType.self).\(keyPath.apiName) should be equal")
        }
    }
}

// MARK: Init Validation

extension DBFringeModelTestProtocol {
    /// Validate the content for the protocol. Should be used during the init phase
    func validateContent(sourceLocation: SourceLocation = #_sourceLocation) throws {
        try #require(try !getDBProperties().isEmpty, "DB model must have at least 1 field", sourceLocation: sourceLocation)
        try #require(try !DBModelType.keyPaths.isEmpty, "KeyPaths must have at least 1 field", sourceLocation: sourceLocation)
        try validateAllFieldsAreAccounted()
    }
    
    /// Ensures all of the fields in the API model are accounted for in the DB model and the keyPaths
    private func validateAllFieldsAreAccounted() throws {
        // Identify properties for the entity and the API model
        let dbProperties = try getDBProperties()
        let apiProperties = Mirror(reflecting: DBModelType.apiModel).children.compactMap(\.label)
        // Identify the properties used by the keyPaths
        let keyPaths = try DBModelType.keyPaths
        let dbKeyPathProperties = keyPaths.map(\.dbName)
        let apiKeyPathProperties = keyPaths.map(\.apiName)
        
        // Ensure that all of the keyPaths match the corresponding properties
        #expect(dbProperties.filter({ !dbKeyPathProperties.contains($0) }) == [])
        #expect(dbKeyPathProperties.filter({ !dbProperties.contains($0) }) == [])
        #expect(apiProperties.filter({ !apiKeyPathProperties.contains($0) }) == [])
        #expect(apiKeyPathProperties.filter({ !apiProperties.contains($0) }) == [])
        
        // Ensure the keyPath array count matches the models properties count
        #expect(dbKeyPathProperties.count == dbProperties.count)
        #expect(apiKeyPathProperties.count == apiProperties.count)
    }
}

// MARK: Properties

extension DBFringeModelTestProtocol {
    private func getDBProperties() throws -> [String] {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DBModelType.self, configurations: config)
        let schema = container.schema
        let entity = try #require(schema.entities.first)
        return entity.properties.map(\.name)
    }
}
