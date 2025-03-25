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
    
    init() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DBFringeEvent.self, DBFringeVenue.self, configurations: config)
        self.testActor = TestDBActor(modelContainer: container)
        self.importAPIActor = ImportAPIActor(modelContainer: container)
        
        // Sanity Check: There should be no models in the database
        try await testActor.performFetch(from: FetchDescriptor<DBFringeVenue>()) { venues in
            try #require(venues.isEmpty, "No Venues should exist")
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
    
    // MARK: Individual Model Updates
    
    @Test("Events will update if changes are found")
    func testEventsWillUpdateIfChangesAreFound() async throws {
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
        
        // Changes should now have been made
        try await testActor.performFetch(from: FetchDescriptor<DBFringeEvent>(predicate: #Predicate { $0.code == updatedEvent1.code })) { events in
            try #require(events.count == 1, "There should still only be 1 modes in the database")
            let event = try #require(events.first)
            #expect(event.title == updatedEvent1.title, "Title should have been updated")
        }
    }
    
    @Test("Venues will update if changes are found")
    func testVenuesWillUpdateIfChangesAreFound() async throws {
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
        let updatedEvent3 = FringeEvent(title: event3.title, subTitle: event3.subTitle, artist: event3.artist, country: event3.country, descriptionTeaser: event3.descriptionTeaser, code: event3.code, ageCategory: event3.ageCategory, description: event3.description, festival: event3.festival, festivalId: event3.festivalId, genre: event3.genre, genreTags: event3.genreTags, performances: event3.performances, performanceSpace: event3.performanceSpace, status: event3.status, url: event3.url, venue: updatedVenue2, website: event3.website, disabled: event3.disabled, images: event3.images, warnings: event3.warnings, updated: event3.updated, year: event3.year)
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
        
        // Changes should now have been made
        try await testActor.performFetch(from: FetchDescriptor<DBFringeVenue>(predicate: #Predicate { $0.code == updatedVenue2.code })) { venues in
            try #require(venues.count == 1, "There should still only be 1 modes in the database")
            let venue = try #require(venues.first)
            #expect(venue.name == updatedVenue2.name, "Name should have been updated")
        }
    }

    @Test("Performances will update if changes are found")
    func testPerformancesWillUpdateIfChangesAreFound() async throws {
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
        // Performances should not include the "UpdatedTitle" as this will be tested later
        try await testActor.performFetch(from: FetchDescriptor<DBFringePerformance>(predicate: #Predicate { $0.start == date1 })) { performances in
            try #require(performances.count == 1, "There should still only be 1 model in the database")
            let performance = try #require(performances.first)
            #expect(performance.title != "UpdatedTitle", "Title should not have test title")
        }

        // Add the events (with the updated performances)
        let apiUpdatedPerformance1 = SeededContent().performance(eventCode: "EVENT1", config: .init(title: .override("UpdatedTitle"), start: .override(apiOriginalPerformance1.start)))
        let apiUpdatedEvent1 = SeededContent().event(config: .init(code: .override("EVENT1"), performances: .override([apiUpdatedPerformance1, apiOriginalPerformance2]), venue: .override(.entireObject(venue))))
        let updatedStatuses = try await importAPIActor.updateEvents([apiUpdatedEvent1, apiOriginalEvent2])
        #expect(updatedStatuses.unorderedElementsEqual([
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .updatedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT1"),
            .updatedModel(type: DBFringePerformance.self, referenceID: apiOriginalPerformance1.referenceID)
        ]))
        // Performance changes should now have been made
        try await testActor.performFetch(from: FetchDescriptor<DBFringePerformance>(predicate: #Predicate { $0.start == date1 })) { performances in
            try #require(performances.count == 1, "There should still only be 1 model in the database")
            let performance = try #require(performances.first)
            #expect(performance.title == "UpdatedTitle", "Title should have been updated")
        }
    }
    
    // MARK: Performance Specific Tests
    
    @Test("Missing performances will become cancelled")
    func testMissingPerformancesWillBecomeCancelled() async throws {
        // Setup models
        let date1 = SeededContent().date()
        let date2 = date1.addingTimeInterval(1000)
        let date3 = date1.addingTimeInterval(2000)
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
        // All performances imported should be active   
        try await testActor.performFetch(from: FetchDescriptor<DBFringePerformance>()) { performances in
            let performance1 = try #require(performances.first { $0.start == apiOriginalPerformance1.start })
            let performance2 = try #require(performances.first { $0.start == apiOriginalPerformance2.start })
            let performance3 = try #require(performances.first { $0.start == apiOriginalPerformance3.start })
            #expect(performance1.status == .active, "Performance 1 should have a status of active")
            #expect(performance2.status == .active, "Performance 2 should have a status of active")
            #expect(performance3.status == .active, "Performance 3 should have a status of active")
        }
        
        // Add the events (with a performance now missing)
        let apiUpdatedEvent1 = SeededContent().event(config: .init(code: .override("EVENT1"), performances: .override([apiOriginalPerformance1]), venue: .override(.entireObject(venue))))
        let updatedStatuses = try await importAPIActor.updateEvents([apiUpdatedEvent1, apiOriginalEvent2])
        #expect(updatedStatuses.unorderedElementsEqual([
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .updatedModel(type: DBFringeEvent.self, referenceID: "Event-EVENT1"),
            .updatedModel(type: DBFringePerformance.self, referenceID: apiOriginalPerformance2.referenceID)
        ]))
        // Only performance 2 should have been cancelled
        try await testActor.performFetch(from: FetchDescriptor<DBFringePerformance>()) { performances in
            let performance1 = try #require(performances.first { $0.start == apiOriginalPerformance1.start })
            let performance2 = try #require(performances.first { $0.start == apiOriginalPerformance2.start })
            let performance3 = try #require(performances.first { $0.start == apiOriginalPerformance3.start })
            #expect(performance1.status == .active, "Performance 1 still existed in event and should remain active")
            #expect(performance2.status == .cancelled, "Performance 2 was not included in the event and should have a status of cancelled")
            #expect(performance3.status == .active, "Performance 3 did not have an event imported and should remain active")
        }
        
        // Add the events (with the performance still missing, no further changes will be made)
        let reUpdatedStatuses = try await importAPIActor.updateEvents([apiUpdatedEvent1, apiOriginalEvent2])
        #expect(reUpdatedStatuses.unorderedElementsEqual([
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges,
            .noChanges
        ]))
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
