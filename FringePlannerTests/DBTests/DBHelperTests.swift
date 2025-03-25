//
//  DBHelperTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 25/03/2025.
//

import SwiftData
import Foundation
import Testing
@testable import FringePlanner

@Suite("DBHelper Tests")
struct DBHelperTests {
    
    private let context: ModelContext
    private static let allVenuesDescriptor = FetchDescriptor<DBFringeVenue>()
    private static let allEventsDescriptor = FetchDescriptor<DBFringeEvent>()
    
    init() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DBFringeEvent.self, DBFringeVenue.self, configurations: config)
        self.context = ModelContext(container)
    }
    
    @Test("Inserts model if missing")
    func testInsertsModelIfMissing() async throws {
        // Insert a model
        let apiModel = SeededContent().venue(config: .init(code: .override("VENUE1")))
        #expect(try DBHelper.updateModel(from: apiModel, modelContext: context) == .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"))
        
        // Test venue has been added
        let venues = try context.fetch(Self.allVenuesDescriptor)
        #expect(venues.count == 1, "Only 1 venue should be created")
        #expect(venues.first == apiModel, "Venue should match the inserted one")
    }
    
    @Test("Updates model if new content is available")
    func testUpdatesModelIfNewContentIsAvailable() async throws {
        // Setup models
        let originalModel = SeededContent().venue(config: .init(code: .override("VENUE1"), name: .override("Original Name")))
        let updatedModel = SeededContent().venue(config: .init(code: .override("VENUE1"), name: .override("Updated Name")))
        try #require(originalModel != updatedModel, "Sanity Check: Models should be different")
        try #require(originalModel.code == updatedModel.code, "Sanity Check Models should share the same code value")
        
        // Add the first model to the database
        #expect(try DBHelper.updateModel(from: originalModel, modelContext: context) == .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"), "Sanity Check: Model should be added to the database")
        #expect(try context.fetch(Self.allVenuesDescriptor).count == 1, "Sanity Check: Model should be added to the database")
        
        // Update the database with a model sharing the same code
        #expect(try DBHelper.updateModel(from: updatedModel, modelContext: context) == .updatedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"), "Sanity Check: Model should be updated in the database")
        // The model should now be updated & not inserted
        let venues = try context.fetch(Self.allVenuesDescriptor)
        #expect(venues.count == 1, "Model should have updated the existing model")
        let venue = try #require(venues.first)
        // Both venues share the same code
        #expect(venue.code == originalModel.code, "Code should not have changed as it matched the previous value")
        #expect(venue.code == updatedModel.code, "Code should not have changed as it matched the previous value")
        // The name was different, causing the update
        #expect(venue.name != originalModel.name, "Name should have changed as it was different to the previous value")
        #expect(venue.name == updatedModel.name, "Name should have changed as it was different to the previous value")
    }
    
    @Test("Inserts models independently if they do not share the same code")
    func testInsertsModelsIndependently() async throws {
        // Setup models
        let venue1 = SeededContent().venue(config: .init(code: .override("VENUE1")))
        let venue2 = SeededContent().venue(config: .init(code: .override("VENUE2")))
        
        // Add models to DB, should be inserts as they are different models
        #expect(try DBHelper.updateModel(from: venue1, modelContext: context) == .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"), "Sanity Check: Model should be added to the database")
        #expect(try DBHelper.updateModel(from: venue2, modelContext: context) == .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE2"), "Sanity Check: Model should be added to the database")
        
        // Test: There should now be two models in the database
        let venues = try context.fetch(Self.allVenuesDescriptor)
        #expect(venues.count == 2, "There should be two models in the database")
        // Both codes should now be in the DB
        #expect(venues.map(\.code).unorderedElementsEqual(["VENUE1", "VENUE2"]))
    }

    @Test("Returns noChanges if model already exists with the same data (Venue)")
    func testReturnsNoChangesIfModelAlreadyExistsWithSameData_Venue() async throws {
        // Setup model
        let venue1 = SeededContent().venue(config: .init(code: .override("VENUE1")))
        // Adding a new model should result in an insert
        #expect(try DBHelper.updateModel(from: venue1, modelContext: context) == .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"), "Sanity Check: Model should be added to the database")
        let venues = try context.fetch(Self.allVenuesDescriptor)
        #expect(venues.count == 1, "There should be 1 model in the database")
        
        // Adding the same model should result in noChanges
        #expect(try DBHelper.updateModel(from: venue1, modelContext: context) == .noChanges, "Model should not be added to the database")
        #expect(try context.fetch(Self.allVenuesDescriptor).count == 1, "There should still only be 1 modes in the database")
    }
  
    @Test("Returns noChanges if model already exists with the same data (Event)")
    func testReturnsNoChangesIfModelAlreadyExistsWithSameData_Event() async throws {
        // Setup model
        let event = SeededContent().event(config: .init(code: .override("EVENT1"), venue: .override(.config(.init(code: .override("VENUE1"))))))
        // Add venues so that relationships can be made for the event
        #expect(try DBHelper.updateModel(from: event.venue, modelContext: context) == .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"), "Sanity Check: Model should be added to the database")
        
        // Adding a new model should result in an insert
        #expect(try DBHelper.updateModel(from: event, modelContext: context) == .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT1"), "Sanity Check: Model should be added to the database")
        #expect(try context.fetch(Self.allEventsDescriptor).count == 1, "There should be 1 model in the database")
        
        // Adding the same model should result in noChanges
        #expect(try DBHelper.updateModel(from: event, modelContext: context) == .noChanges, "Model should not be added to the database")
        #expect(try context.fetch(Self.allEventsDescriptor).count == 1, "There should still only be 1 modes in the database")
    }
}

extension DBHelperTests {
    @Suite("Insert Model Tests")
    struct InsertModelTests {
        
        @Test("Insert will throw if the container is not setup for the model type")
        func testMissingContainerThrows() throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(configurations: config)
            let context = ModelContext(container)
            
            #expect(throws: DBError.insertFailed(.modelNotFoundInSchema)) {
                try DBHelper.insertModel(from: DBFringeVenue.apiModel, modelContext: context)
            }
        }

        @Test("Insert will not throw if the container is setup for the model type")
        func testSetupContainerDoesNotThrow() throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: DBFringeVenue.self, configurations: config)
            let context = ModelContext(container)
            
            #expect(try DBHelper.insertModel(from: DBFringeVenue.apiModel, modelContext: context) == .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-TEST123"))
        }
    }
}
