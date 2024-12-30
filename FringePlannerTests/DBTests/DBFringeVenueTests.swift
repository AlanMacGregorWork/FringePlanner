//
//  DBFringeVenueTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 28/12/2024.
//

import Foundation
import Testing
@testable import FringePlanner

@Suite("DBFringeVenue Tests")
struct DBFringeVenueTests {
    
    init() throws {
        try validateContent()
    }
    
    @Test("Database model is correctly updated from API model")
    func testUpdateCopiesAllFields() throws {
        try autoTestUpdateCopiesAllFields()
    }
}

// MARK: DBFringeModelTestProtocol

extension DBFringeVenueTests: DBFringeModelTestProtocol {
    var keyPaths: [KeyPathCheck<DBFringeVenue, FringeVenue>] {
        get throws { try [
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
        ] }
    }
    var apiModel: FringeVenue {
        FringeVenue(
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
    }
    var dbModel: DBFringeVenue {
        DBFringeVenue(
            code: "ORIGINAL",
            name: "Original Name",
            position: .init(lat: 0, lon: 0),
            postCode: "Original"
        )
    }
}
