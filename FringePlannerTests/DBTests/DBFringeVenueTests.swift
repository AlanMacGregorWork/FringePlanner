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
struct DBFringeVenueTests: DBFringeModelTestProtocol {
    typealias DBModelType = DBFringeVenue
    
    init() throws {
        try validateContent()
    }
    
    @Test("Database model is correctly updated from API model")
    func testUpdateCopiesAllFields() throws {
        try autoTestUpdateCopiesAllFields()
    }

    @Test("Equatable checks match properties")
    func testEquatableChecksMatchProperties() throws {
        try autoTestEquatableChecksMatchProperties()
    }
    
    @Test("`updated` field should not be in db model")
    func testUpdatedFieldIsNotPresentInDBModel() throws {
        try autoTestUpdatedFieldIsNotPresentInDBModel()
    }
    
    @Test("Predicate identifies correct models")
    func testPredicateIdentifiesCorrectModels() throws {
        let mockPosition = FringeVenue.Position(lat: 23, lon: 43)
        let mockAPIModel = FringeVenue(code: "ABC123", description: "A historic theatre in Edinburgh", name: "The Royal Theatre", address: "123 Royal Mile", position: mockPosition, postCode: "EH1 1AA", webAddress: URL(string: "https://royaltheatre.com"), phone: "+44 131 123 4567", email: "info@royaltheatre.com", disabledDescription: "Wheelchair accessible")
        let mockDBModel1 = DBFringeVenue(code: "ABC123", venueDescription: "Different Desc", name: "The Royal Theatre", address: "123 Royal Mile", position: mockPosition, postCode: "EH1 1AA", webAddress: URL(string: "https://royaltheatre.com"), phone: "+44 131 123 4567", email: "info@royaltheatre.com", disabledDescription: "Wheelchair accessible")
        let mockDBModel2 = DBFringeVenue(code: "XYZ789", venueDescription: "Modern performance space", name: "Edinburgh Arts Hub", address: "45 Chambers Street", position: mockPosition, postCode: "EH1 1JF", webAddress: URL(string: "https://artshub.com"), phone: "+44 131 987 6543", email: "contact@artshub.com", disabledDescription: "Full accessibility")
        
        try autoTestPredicateIdentifiesCorrectModels(mockAPIModel: mockAPIModel, mockDBModel1: mockDBModel1, mockDBModel2: mockDBModel2)
    }
}
