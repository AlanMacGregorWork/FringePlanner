//
//  DBFringeVenueTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 28/12/2024.
//

import Foundation
import Testing
import SwiftData
@testable import FringePlanner

@Suite("DBFringeVenue Tests")
struct DBFringeVenueTests {
    
    // MARK: Properties
    
    let dbProperties: [String]
    let apiProperties: [String]
    let keyPaths: [KeyPathCheck]
    let venue = FringeVenue(
        code: "TEST123",
        description: "Test Description",
        name: "Test Venue",
        address: "123 Test Street",
        position: .init(lat: 55.9533, lon: -3.1883),
        postCode: "EH1 1AB",
        webAddress: URL(string: "https://example.com")!,
        phone: "01234567890",
        email: "test@example.com",
        disabledDescription: "Accessible entrance"
    )
    
    // MARK: Init
    
    @MainActor
    init() throws {
        let container = try ModelContainer(for: DBFringeVenue.self)
        let schema = container.schema
        let entity = try #require(schema.entities.first)
        self.dbProperties = entity.properties.map(\.name)
        try #require(!dbProperties.isEmpty, "DB model must have at least 1 field")
        self.apiProperties = Mirror(reflecting: venue).children.compactMap(\.label)
        self.keyPaths = try [
            .init(dbKeyPath: \.code, apiKeyPath: \.code),
            .init(dbKeyPath: \.venueDescription, apiKeyPath: \.description),
            .init(dbKeyPath: \.name, apiKeyPath: \.name),
            .init(dbKeyPath: \.address, apiKeyPath: \.address),
            .init(dbKeyPath: \.position, apiKeyPath: \.position),
            .init(dbKeyPath: \.postCode, apiKeyPath: \.postCode),
            .init(dbKeyPath: \.webAddress, apiKeyPath: \.webAddress),
            .init(dbKeyPath: \.phone, apiKeyPath: \.phone),
            .init(dbKeyPath: \.email, apiKeyPath: \.email),
            .init(dbKeyPath: \.disabledDescription, apiKeyPath: \.disabledDescription)
        ]
    }
}

// MARK: - Tests

extension DBFringeVenueTests {
    @Test("Verify all test fields are accounted")
    func testAllFieldsAreAccounted() {
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
    
    @Test("Database correctly updates from API model")
    func venueUpdateCopiesAllFields() throws {
        let dbVenue = DBFringeVenue(
            code: "ORIGINAL",
            name: "Original Name",
            position: .init(lat: 0, lon: 0),
            postCode: "Original"
        )
        
        // Verify that all of the fields in both models are different
        for keyPath in keyPaths {
            try #require(!keyPath.equate(dbVenue, venue), "\(keyPath.dbName) should not be equal")
        }
        // Update the model
        dbVenue.update(from: venue)
        
        // Test that all of the fields now match
        for keyPath in keyPaths {
            #expect(keyPath.equate(dbVenue, venue), "\(keyPath.dbName) should be equal")
        }
    }
}

/// A struct to check if two models are equal at their key paths
/// - Note: `@unchecked` is included as its use is only for tests, and will only call `equate` once the model is updated
struct KeyPathCheck: @unchecked Sendable {
    let dbName: String
    let apiName: String
    let equate: ((DBFringeVenue, FringeVenue) -> (Bool))
    
    init<T: Equatable>(dbKeyPath: KeyPath<DBFringeVenue, T>, apiKeyPath: KeyPath<FringeVenue, T>) throws {
        dbName = try #require(String(describing: dbKeyPath).components(separatedBy: ".").last)
        apiName = try #require(String(describing: apiKeyPath).components(separatedBy: ".").last)
        equate = { dbModel, apiModel in
            dbModel[keyPath: dbKeyPath] == apiModel[keyPath: apiKeyPath]
        }
    }
}
