//
//  ImportAPIActorTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 25/01/2025.
//

import SwiftData
import Foundation
import Testing
@testable import FringePlanner

@Suite("ImportAPIActor Tests")
struct ImportAPIActorTests {
    private let testActor: TestDBActor
    private let importAPIActor: ImportAPIActor
    private static let allVenuesDescriptor = FetchDescriptor<DBFringeVenue>()
    private static let allEventsDescriptor = FetchDescriptor<DBFringeEvent>()
    private static let allPerformancesDescriptor = FetchDescriptor<DBFringePerformance>()
    
    init() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DBFringeEvent.self, DBFringeVenue.self, configurations: config)
        self.testActor = TestDBActor(modelContainer: container)
        self.importAPIActor = ImportAPIActor(modelContainer: container)
        
        // Sanity Check: There should be no models in the database
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            try #require(venues.isEmpty, "No Venues should exist")
        }
    }
    
    @Test("Inserts model if missing")
    func testInsertsModelIfMissing() async throws {
        // Update the database from the API models
        let apiModel = SeededContent().venue(config: .init(code: .override("VENUE1")))
        try await addModelToDB(apiModel, expecting: .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"))
        
        // Test: There should now be one model in the database
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            #expect(venues.count == 1, "Venue should have been added")
            #expect(venues.first == apiModel, "Venue should have been added")
        }
    }
    
    @Test("Updates model if new content is available")
    func testUpdatesModelIfNewContentIsAvailable() async throws {
        // Setup models
        let originalModel = SeededContent().venue(config: .init(code: .override("VENUE1"), name: .override("Original Name")))
        let updatedModel = SeededContent().venue(config: .init(code: .override("VENUE1"), name: .override("Updated Name")))
        // Sanity Check
        try #require(originalModel != updatedModel, "Sanity Check: Models should be different")
        try #require(originalModel.code == updatedModel.code, "Sanity Check Models should share the same code value")
        
        // Add the first model to the database
        try await addModelToDB(originalModel, expecting: .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"))
        // The model should now be in the database
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            #expect(venues.count == 1)
        }
        
        // Update the database with a model sharing the same code
        try await addModelToDB(updatedModel, expecting: .updatedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"))
        // The model should now be updated & not inserted
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            #expect(venues.count == 1, "Model should have updated the existing model")
            let venue = try #require(venues.first)
            // Both venues share the same code
            #expect(venue.code == originalModel.code, "Code should not have changed as it matched the previous value")
            #expect(venue.code == updatedModel.code, "Code should not have changed as it matched the previous value")
            // The name was different, causing the update
            #expect(venue.name != originalModel.name, "Name should have changed as it was different to the previous value")
            #expect(venue.name == updatedModel.name, "Name should have changed as it was different to the previous value")
        }
    }
    
    @Test("Inserts models independently if they do not share the same code")
    func testInsertsModelsIndependently() async throws {
        // Setup models
        let venue1 = SeededContent().venue(config: .init(code: .override("VENUE1")))
        let venue2 = SeededContent().venue(config: .init(code: .override("VENUE2")))
        
        // Add models to DB, should be inserts as they are different models
        try await addModelToDB(venue1, expecting: .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"))
        try await addModelToDB(venue2, expecting: .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE2"))
        
        // Test: There should now be two models in the database
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            #expect(venues.count == 2, "There should be two models in the database")
            // Both codes should now be in the DB
            #expect(venues.map(\.code).unorderedElementsEqual(["VENUE1", "VENUE2"]))
        }
    }

    @Test("Returns noChanges if model already exists with the same data (Venue)")
    func testReturnsNoChangesIfModelAlreadyExistsWithSameData_Venue() async throws {
        // Setup model
        let venue1 = SeededContent().venue(config: .init(code: .override("VENUE1")))
        // Adding a new model should result in an insert
        try await addModelToDB(venue1, expecting: .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"))
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            #expect(venues.count == 1, "There should be 1 model in the database")
        }
        
        // Adding the same model should result in noChanges
        try await addModelToDB(venue1, expecting: .noChanges)
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            #expect(venues.count == 1, "There should still only be 1 modes in the database")
        }
    }
    
    @Test("Returns noChanges if model already exists with the same data (Event)")
    func testReturnsNoChangesIfModelAlreadyExistsWithSameData_Event() async throws {
        // Setup model
        let event = SeededContent().event(config: .init(code: .override("EVENT1"), venue: .override(.config(.init(code: .override("VENUE1"))))))
        
        // Add venues so that relationships can be made for the event
        try await addModelToDB(event.venue, expecting: .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"))
        
        // Adding a new model should result in an insert
        try await addModelToDB(event, expecting: .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT1"))
        try await testActor.performFetch(from: Self.allEventsDescriptor) { events in
            #expect(events.count == 1, "There should be 1 model in the database")
        }
        
        // Adding the same model should result in noChanges
        try await addModelToDB(event, expecting: .noChanges)
        try await testActor.performFetch(from: Self.allEventsDescriptor) { events in
            #expect(events.count == 1, "There should still only be 1 modes in the database")
        }
    }
    
    @Test("Events insert if they do not exist")
    func testEventsInsertIfTheyDoNotExist() async throws {
        // Setup models
        let performances = SeededContent.OverrideSeedValue<[FringePerformance]>.override([])
        let event1 = SeededContent().event(config: .init(code: .override("EVENT1"), performances: performances, venue: .override(.config(.init(code: .override("VENUE1"))))))
        let event2 = SeededContent().event(config: .init(code: .override("EVENT2"), performances: performances, venue: .override(.config(.init(code: .override("VENUE2"))))))
        let event3 = SeededContent().event(config: .init(code: .override("EVENT3"), performances: performances, venue: .override(.entireObject(event1.venue))))

        // Importing the events should insert 5 models
        let initialStatuses = try await importAPIActor.updateEvents([event1, event2, event3])
        #expect(initialStatuses.unorderedElementsEqual([
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT1"),
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT2"),
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT3"),
            .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"),
            .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE2"),
            .noChanges // Duplicate Venue
        ]), "All expected statuses should be present")
    }
    
    @Test("Events do not insert or update if changes do not exist")
    func testEventsDoNotInsertOrUpdateIfChangesDoNotExist() async throws {
        // Setup models
        let performances = SeededContent.OverrideSeedValue<[FringePerformance]>.override([])
        let event1 = SeededContent().event(config: .init(code: .override("EVENT1"), performances: performances, venue: .override(.config(.init(code: .override("VENUE1"))))))
        let event2 = SeededContent().event(config: .init(code: .override("EVENT2"), performances: performances, venue: .override(.config(.init(code: .override("VENUE2"))))))
        let event3 = SeededContent().event(config: .init(code: .override("EVENT3"), performances: performances, venue: .override(.entireObject(event1.venue))))

        // Importing the events should insert 5 models
        let initialStatuses = try await importAPIActor.updateEvents([event1, event2, event3])
        #expect(initialStatuses.unorderedElementsEqual([
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT1"),
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT2"),
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT3"),
            .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"),
            .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE2"),
            .noChanges // Duplicate Venue (Event 1 & 3)
        ]), "All expected statuses should be present")

        // Attempting to re-import the events should make no changes
        let reimportedStatuses = try await importAPIActor.updateEvents([event1, event2, event3])
        #expect(reimportedStatuses.unorderedElementsEqual([
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges // Duplicate Venue
        ]), "Content already exists so does not require updating")
    }
    
    @Test("Events will update if changes are found")
    func testEventsWillUpdateIfChangesAreFound_Event() async throws {
        // Setup models
        let performances = SeededContent.OverrideSeedValue<[FringePerformance]>.override([])
        let event1 = SeededContent().event(config: .init(code: .override("EVENT1"), performances: performances, venue: .override(.config(.init(code: .override("VENUE1"))))))
        let event2 = SeededContent().event(config: .init(code: .override("EVENT2"), performances: performances, venue: .override(.entireObject(event1.venue))))
        let event3 = SeededContent().event(config: .init(code: .override("EVENT3"), performances: performances, venue: .override(.config(.init(code: .override("VENUE2"))))))

        // Importing the events should insert 5 models
        let initialStatuses = try await importAPIActor.updateEvents([event1, event2, event3])
        #expect(initialStatuses.unorderedElementsEqual([
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT1"),
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT2"),
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT3"),
            .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"),
            .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE2"),
            .noChanges // Duplicate Venue
        ]), "All expected statuses should be present")

        // Create a new event with a changed title
        let updatedEvent1 = SeededContent().event(config: .init(code: .override("EVENT1"), title: .override("Title Changed"), performances: performances, venue: .override(.entireObject(event1.venue))))
        try #require(updatedEvent1 != event1, "Sanity Check: Models should be different")
        try #require(updatedEvent1.title != event1.title, "Sanity Check: Models should be different")
        try #require(updatedEvent1.code == event1.code, "Sanity Check: Models should share the same code value")

        // Update the event in the database
        let updatedStatuses = try await importAPIActor.updateEvents([updatedEvent1, event2, event3])
        #expect(updatedStatuses.unorderedElementsEqual([
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .updatedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT1")
        ]), "Only the first event should have been updated")
        try await importAPIActor.saveChanges()
        
        // Changes should now have been made
        try await testActor.performFetch(from: FetchDescriptor<DBFringeEvent>(predicate: #Predicate { $0.code == updatedEvent1.code })) { events in
            try #require(events.count == 1, "There should still only be 1 modes in the database")
            let event = try #require(events.first)
            #expect(event.title == updatedEvent1.title, "Title should have been updated")
        }
    }
    
    @Test("Venues will update if changes are found")
    func testVenuesWillUpdateIfChangesAreFound_Venue() async throws {
        // Setup models
        let performances = SeededContent.OverrideSeedValue<[FringePerformance]>.override([])
        let event1 = SeededContent().event(config: .init(code: .override("EVENT1"), performances: performances, venue: .override(.config(.init(code: .override("VENUE1"))))))
        let event2 = SeededContent().event(config: .init(code: .override("EVENT2"), performances: performances, venue: .override(.entireObject(event1.venue))))
        let event3 = SeededContent().event(config: .init(code: .override("EVENT3"), performances: performances, venue: .override(.config(.init(code: .override("VENUE2"))))))

        // Importing the events should insert 5 models
        let initialStatuses = try await importAPIActor.updateEvents([event1, event2, event3])
        #expect(initialStatuses.unorderedElementsEqual([
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT1"),
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT2"),
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT3"),
            .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"),
            .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE2"),
            .noChanges
        ]), "All expected statuses should be present")

        // Create a venue that has a changed name
        let updatedVenue2 = SeededContent().venue(config: .init(code: .override("VENUE2"), name: .override("Updated NAME")))
        let updatedEvent3 = FringeEvent(title: event3.title, artist: event3.artist, country: event3.country, descriptionTeaser: event3.descriptionTeaser, code: event3.code, ageCategory: event3.ageCategory, description: event3.description, festival: event3.festival, festivalId: event3.festivalId, genre: event3.genre, genreTags: event3.genreTags, performances: event3.performances, performanceSpace: event3.performanceSpace, status: event3.status, url: event3.url, venue: updatedVenue2, website: event3.website, disabled: event3.disabled, images: event3.images, warnings: event3.warnings, updated: event3.updated, year: event3.year)
        try #require(updatedVenue2 != event2.venue, "Sanity Check: Models should be different")
        try #require(updatedVenue2.name != event3.venue.name, "Sanity Check: Models should be different")
        try #require(updatedVenue2.code == event3.venue.code, "Sanity Check: Models should share the same code value")
        try #require(updatedEvent3.code == event3.code, "Sanity Check: Models should share the same code value")

        // Update the event in the database
        let updatedStatuses = try await importAPIActor.updateEvents([event1, event2, updatedEvent3])
        #expect(updatedStatuses.unorderedElementsEqual([
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .updatedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE2")
        ]), "Only the venue should have been updated")
        try await importAPIActor.saveChanges()
        
        // Changes should now have been made
        try await testActor.performFetch(from: FetchDescriptor<DBFringeVenue>(predicate: #Predicate { $0.code == updatedVenue2.code })) { venues in
            try #require(venues.count == 1, "There should still only be 1 modes in the database")
            let venue = try #require(venues.first)
            #expect(venue.name == updatedVenue2.name, "Name should have been updated")
        }
    }

    @Test("Performances will update if changes are found")
    func testPerformancesWillUpdateIfChangesAreFound_Performance() async throws {
        // Setup models
        let date1 = SeededContent().date()
        let date2 = date1.addingTimeInterval(60)
        let date3 = date1.addingTimeInterval(120)
        let venue = SeededContent().venue(config: .init(code: .override("VENUE1")))
        let apiOriginalPerformance1 = SeededContent().performance(eventCode: "EVENT1", config: .init(title: .override("Title1"), start: .override(date1)))
        let apiOriginalPerformance2 = SeededContent().performance(eventCode: "EVENT1", config: .init(title: .override("Title2"), start: .override(date2)))
        let apiOriginalPerformance3 = SeededContent().performance(eventCode: "EVENT2", config: .init(title: .override("Title3"), start: .override(date3)))
        let apiOriginalEvent1 = SeededContent().event(config: .init(code: .override("EVENT1"), performances: .override([apiOriginalPerformance1, apiOriginalPerformance2]), venue: .override(.entireObject(venue))))
        let apiOriginalEvent2 = SeededContent().event(config: .init(code: .override("EVENT2"), performances: .override([apiOriginalPerformance3]), venue: .override(.entireObject(venue))))
        
        // Add the events
        let initialStatuses = try await importAPIActor.updateEvents([apiOriginalEvent1, apiOriginalEvent2])
        #expect(initialStatuses.unorderedElementsEqual([
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT1"),
            .insertedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT2"),
            .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-VENUE1"),
            .insertedModel(type: DBFringePerformance.self, referenceID: apiOriginalPerformance1.referenceID),
            .insertedModel(type: DBFringePerformance.self, referenceID: apiOriginalPerformance2.referenceID),
            .insertedModel(type: DBFringePerformance.self, referenceID: apiOriginalPerformance3.referenceID),
            .noChanges
        ]), "All expected statuses should be present")

        // Add the events (with the updated performances)
        let apiUpdatedPerformance1 = SeededContent().performance(eventCode: "EVENT1", config: .init(title: .override("UpdatedTitle"), start: .override(date1)))
        let apiUpdatedEvent1 = SeededContent().event(config: .init(code: .override("EVENT1"), performances: .override([apiUpdatedPerformance1]), venue: .override(.entireObject(venue))))
        let updatedStatuses = try await importAPIActor.updateEvents([apiUpdatedEvent1, apiOriginalEvent2])
        #expect(updatedStatuses.unorderedElementsEqual([
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .updatedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT1"),
            .updatedModel(type: DBFringePerformance.self, referenceID: apiOriginalPerformance1.referenceID)
        ]))
        try await importAPIActor.saveChanges()

        // Performance changes should now have been made
        try await testActor.performFetch(from: FetchDescriptor<DBFringePerformance>(predicate: #Predicate { $0.eventCode == apiUpdatedPerformance1.eventCode && $0.start == apiUpdatedPerformance1.start })) { performances in
            try #require(performances.count == 1, "There should still only be 1 modes in the database")
            let performance = try #require(performances.first)
            #expect(performance.title == "UpdatedTitle", "Title should have been updated")
        }
    }

    // MARK: Helper
    
    /// Simplifies the update execution of the DB actor and verifies the state is correct
    private func addModelToDB<APIFringeModelType: APIFringeModel>(
        _ apiModel: APIFringeModelType,
        expecting status: ImportAPIActor.Status,
        saveChanges: Bool = true,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async throws(DBError) {
        let dbStatus = try await importAPIActor.updateModel(from: apiModel)
        #expect(dbStatus == status, "Model should have status `\(status)`", sourceLocation: sourceLocation)
        switch status {
        case .insertedModel, .updatedModel:
            #expect(await importAPIActor.hasChanges, "Changes should not have been saved yet", sourceLocation: sourceLocation)
            if saveChanges {
                try await importAPIActor.saveChanges()
                #expect(await !importAPIActor.hasChanges, "Changes should now have been saved.", sourceLocation: sourceLocation)
            }
        case .noChanges:
            #expect(await !importAPIActor.hasChanges, "No changes should exist", sourceLocation: sourceLocation)
        }
    }
}

extension ImportAPIActorTests {
    @Suite("Insert Model Tests")
    struct InsertModelTests {
        
        @Test("Insert will throw if the container is not setup for the model type")
        func testMissingContainerThrows() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(configurations: config)
            let insertActor = ImportAPIActor(modelContainer: container)
            
            try await #require(throws: DBError.insertFailed(.modelDidNotInsertIntoContext)) {
                try await insertActor.insertModel(from: DBFringeVenue.apiModel)
            }
        }

        @Test("Insert will not throw if the container is setup for the model type")
        func testSetupContainerDoesNotThrow() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: DBFringeVenue.self, configurations: config)
            let insertActor = ImportAPIActor(modelContainer: container)
            
            #expect(try await insertActor.insertModel(from: DBFringeVenue.apiModel) == .insertedModel(type: DBFringeVenue.self, referenceID: "Venue-TEST123"))
        }
    }
}

/// Allows performing tests on a fetch inside an actor
@ModelActor
actor TestDBActor {
    func performFetch<T: PersistentModel>(from descriptor: FetchDescriptor<T>, _ check: (([T]) throws -> Void)) throws {
        let existingModels = try modelContext.fetch(descriptor)
        try check(existingModels)
    }
}
