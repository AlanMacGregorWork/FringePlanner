//
//  DBFringeEventTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 11/01/2025.
//

import Foundation
import Testing
import SwiftData
@testable import FringePlanner

@Suite("DBFringeEvent Tests")
struct DBFringeEventTests: DBFringeModelTestProtocol {
    typealias DBModelType = DBFringeEvent
    
    init() throws {
        try validateContent()
    }
    
    @Test("Database model is correctly updated from API model")
    func testUpdateCopiesAllFields() throws {
        try autoTestUpdateCopiesAllFields()
    }

    @Test("Key paths match properties")
    func testEquatableChecksMatchProperties() throws {
        try autoTestEquatableChecksMatchProperties()
    }
    
    @Test("`updated` field should not be in db model")
    func testUpdatedFieldIsNotPresentInDBModel() throws {
        try autoTestUpdatedFieldIsNotPresentInDBModel()
    }

    @Test("Predicate identifies correct models")
    func testPredicateIdentifiesCorrectModels() throws {
        // Setup Database
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DBFringeEvent.self, DBFringeVenue.self, configurations: config)
        let context = ModelContext(container)
        // Create the mock API model
        let venueConfig = SeededContent.OverrideSeedVenueValue.config(.init(code: .override("Venue")))
        let mockAPIModel = SeededContent().event(config: .init(code: .override("Event1"), venue: .override(venueConfig)))
        // Add venue to the context so the events can create the relationship
        let dbVenue = try DBFringeVenue(apiModel: mockAPIModel.venue, context: context)
        context.insert(dbVenue)
        // Create mock database models
        let mockDBModel1 = try DBFringeEvent(apiModel: SeededContent().event(config: .init(code: .override("Event1"), venue: .override(venueConfig))), context: context)
        let mockDBModel2 = try DBFringeEvent(apiModel: SeededContent().event(config: .init(code: .override("Event2"), venue: .override(venueConfig))), context: context)
        
        // Verify content. DB models should not equate to API model but the DB model `code` should match the API model `code`
        try #require(mockAPIModel != mockDBModel1, "DB & API models should not match")
        try #require(mockAPIModel != mockDBModel2, "DB & API models should not match")
        try #require(mockAPIModel.code == mockDBModel1.code, "DB model #1 code should match API model code")
        try #require(mockAPIModel.code != mockDBModel2.code, "DB model #2 code should not match API model code")

        try autoTestPredicateIdentifiesCorrectModels(mockAPIModel: mockAPIModel, mockDBModel1: mockDBModel1, mockDBModel2: mockDBModel2)
    }
}
