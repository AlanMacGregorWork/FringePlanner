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
    func testPredicateIdentifiesCorrectModels() throws
    func testUpdatedFieldIsNotPresentInDBModel() throws 
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

        // Ensure that all of the properties match the equatable checks
        let dbMissing = dbProperties
            // Filter out the omitted fields
            .filter({ !DBModelType.omittedDBAndAPIFields.dbFields.contains($0) })
            // Filter out the equatable checks that don't match the property
            .filter({ !equatableChecks.map(\.lhsName).contains($0) })
        #expect(dbMissing == [], "DB properties missing from equatable checks: \(dbMissing)", sourceLocation: sourceLocation)
        let apiMissing = apiProperties
            // Filter out the omitted fields
            .filter({ !DBModelType.omittedDBAndAPIFields.apiFields.contains($0) })
            // Filter out the equatable checks that don't match the property
            .filter({ !equatableChecks.map(\.rhsName).contains($0) })
        #expect(apiMissing == [], "API properties missing from equatable checks: \(apiMissing)", sourceLocation: sourceLocation)

        // Ensure that all of the equatable checks match the corresponding properties
        let apiExtra = equatableChecks.map(\.rhsName).filter({ !apiProperties.contains($0) })
        #expect(apiExtra == [], "Extra API equatable checks names that don't match any properties: \(apiExtra)", sourceLocation: sourceLocation)
        let dbExtra = equatableChecks.map(\.lhsName).filter({ !dbProperties.contains($0) })
        #expect(dbExtra == [], "Extra DB equatable checks names that don't match any properties: \(dbExtra)", sourceLocation: sourceLocation)

        // Verify property count matches
        #expect(equatableChecks.map(\.lhsName).count == dbProperties.count - DBModelType.omittedDBAndAPIFields.dbFields.count,
                "DB equatable checks count (\(equatableChecks.map(\.lhsName).count)) doesn't match property count (\(dbProperties.count))",
                sourceLocation: sourceLocation)
        #expect(equatableChecks.map(\.rhsName).count == apiProperties.count - DBModelType.omittedDBAndAPIFields.apiFields.count,
                "API equatable checks count (\(equatableChecks.map(\.rhsName).count)) doesn't match property count (\(apiProperties.count))",
                sourceLocation: sourceLocation)
    }   

    func autoTestPredicateIdentifiesCorrectModels(mockAPIModel: DBModelType.APIFringeModelType, mockDBModel1: DBModelType, mockDBModel2: DBModelType, sourceLocation: SourceLocation = #_sourceLocation) throws {        
        // Test
        // Testing multiple models should return the correct model regardless of order
        try #expect([mockDBModel1, mockDBModel2].filter(DBModelType.predicate(forMatchingAPIModel: mockAPIModel)) == [mockDBModel1], "DB model #1 should match API model")
        try #expect([mockDBModel2, mockDBModel1].filter(DBModelType.predicate(forMatchingAPIModel: mockAPIModel)) == [mockDBModel1], "DB model #1 should match API model")
        // Testing a single model should return the correct model
        try #expect([mockDBModel1].filter(DBModelType.predicate(forMatchingAPIModel: mockAPIModel)) == [mockDBModel1], "DB model #1 should match API model")
        // Testing a single model that doesn't match should return an empty array
        try #expect([mockDBModel2].filter(DBModelType.predicate(forMatchingAPIModel: mockAPIModel)) == [], "DB model #2 should not match API model")
    }
    
    func autoTestUpdatedFieldIsNotPresentInDBModel(sourceLocation: SourceLocation = #_sourceLocation) throws {
        // Note: There is an issue in SwiftData where the `updated` field does not appear to return the
        // value correctly, so it should not be used. This is identified in `testUpdatedFieldIsLost`
        let dbProperties = Mirror(reflecting: DBModelType.dbModel).children.compactMap(\.label)
        // Database properties will all use an underscore prefix
        #expect(!dbProperties.contains("_updated"), "`updated` field should not be in the DB model", sourceLocation: sourceLocation)
    }
}

// MARK: Init Validation

extension DBFringeModelTestProtocol {
    /// Validate the content for the protocol. Should be used during the init phase
    func validateContent(sourceLocation: SourceLocation = #_sourceLocation) throws {
        let dbProperties = try getDBProperties()
        let apiProperties = Mirror(reflecting: DBModelType.apiModel).children.compactMap(\.label)
        for dbField in DBModelType.omittedDBAndAPIFields.dbFields {
            try #require(dbProperties.contains(dbField), "Omitted field \"\(dbField)\" should be in the DB properties", sourceLocation: sourceLocation)    
        }
        for apiField in DBModelType.omittedDBAndAPIFields.apiFields {
            try #require(apiProperties.contains(apiField), "Omitted field \"\(apiField)\" should be in the API properties", sourceLocation: sourceLocation)
        }
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
