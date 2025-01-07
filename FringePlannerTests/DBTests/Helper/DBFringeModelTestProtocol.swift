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
    func testUpdateCopiesAllFields() throws
    func testEquatableChecksMatchProperties() throws
}

// MARK: Test

extension DBFringeModelTestProtocol {
    /// Test that the update method copies all of the fields from the API model to the DB model
    func autoTestUpdateCopiesAllFields(sourceLocation: SourceLocation = #_sourceLocation) throws {
        // Store the variables to avoid re-generating them
        let dbModel = DBModelType.dbModel
        let equatableChecks = DBModelType.equatableChecksForDBAndAPI
        let apiModel = DBModelType.apiModel
        
        // Verify that all of the fields in both models are different
        for equatableCheck in equatableChecks {
            try #require(!equatableCheck.isEqual(lhs: dbModel, rhs: apiModel), "\(DBModelType.self).\(equatableCheck.lhsName) & \(DBModelType.APIFringeModelType.self).\(equatableCheck.rhsName) should not be equal", sourceLocation: sourceLocation)
        }
        // Update the model
        dbModel.update(from: apiModel)
        
        // Test that all of the fields now match
        for equatableCheck in equatableChecks {
            #expect(equatableCheck.isEqual(lhs: dbModel, rhs: apiModel), "\(DBModelType.self).\(equatableCheck.lhsName) & \(DBModelType.APIFringeModelType.self).\(equatableCheck.rhsName) should be equal", sourceLocation: sourceLocation)
        }
    }

    func autoTestEquatableChecksMatchProperties(sourceLocation: SourceLocation = #_sourceLocation) throws {
        let equatableChecks = DBModelType.equatableChecksForDBAndAPI
        let dbProperties = try getDBProperties()
        let apiProperties = Mirror(reflecting: DBModelType.apiModel).children.compactMap(\.label)

        // Ensure that all of the equatable checks match the corresponding properties
        let dbMissing = dbProperties.filter({ !equatableChecks.map(\.lhsName).contains($0) })
        #expect(dbMissing.isEmpty, "DB properties missing from equatable checks: \(dbMissing)", sourceLocation: sourceLocation)

        let apiMissing = apiProperties.filter({ !equatableChecks.map(\.rhsName).contains($0) })
        #expect(apiMissing.isEmpty, "API properties missing from equatable checks: \(apiMissing)", sourceLocation: sourceLocation)

        let apiExtra = equatableChecks.map(\.rhsName).filter({ !apiProperties.contains($0) })
        #expect(apiExtra.isEmpty, "Extra API equatable checks names that don't match any properties: \(apiExtra)", sourceLocation: sourceLocation)

        let dbExtra = equatableChecks.map(\.lhsName).filter({ !dbProperties.contains($0) })
        #expect(dbExtra.isEmpty, "Extra DB equatable checks names that don't match any properties: \(dbExtra)", sourceLocation: sourceLocation)

        // Verify property count matches
        #expect(equatableChecks.map(\.lhsName).count == dbProperties.count,
                "DB equatable checks count (\(equatableChecks.map(\.lhsName).count)) doesn't match property count (\(dbProperties.count))",
                sourceLocation: sourceLocation)

        #expect(equatableChecks.map(\.rhsName).count == apiProperties.count,
                "API equatable checks count (\(equatableChecks.map(\.rhsName).count)) doesn't match property count (\(apiProperties.count))",
                sourceLocation: sourceLocation)
    }   
}

// MARK: Init Validation

extension DBFringeModelTestProtocol {
    /// Validate the content for the protocol. Should be used during the init phase
    func validateContent(sourceLocation: SourceLocation = #_sourceLocation) throws {
        try #require(try !getDBProperties().isEmpty, "DB model must have at least 1 field", sourceLocation: sourceLocation)
        try #require(!DBModelType.equatableChecksForDBAndAPI.isEmpty, "EquatableChecks must have at least 1 field", sourceLocation: sourceLocation)
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
