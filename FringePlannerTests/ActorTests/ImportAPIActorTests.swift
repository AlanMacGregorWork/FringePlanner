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
    private static let mockFringeVenue1 = FringeVenue(code: "VENUE1", description: nil, name: "Mock Venue 1", address: "123 Mock St", position: .init(lat: 55.9533, lon: -3.1883), postCode: "12345", webAddress: nil, phone: nil, email: nil, disabledDescription: nil)
    private static let mockFringeVenue2 = FringeVenue(code: "VENUE2", description: nil, name: "Mock Venue 2", address: "456 Example Ave", position: .init(lat: 55.9533, lon: -3.1883), postCode: "67890", webAddress: nil, phone: nil, email: nil, disabledDescription: nil)
    private static let mockFringeVenue3 = FringeVenue(code: "VENUE1", description: nil, name: "Some other name", address: "789 Test Road", position: .init(lat: 55.9533, lon: -3.1883), postCode: "24680", webAddress: nil, phone: nil, email: nil, disabledDescription: nil)
    private static let mockEvent1 = FringeEvent(title: "Hamlet Reimagined", artist: "Shakespeare Company", country: "United Kingdom", descriptionTeaser: "A modern take on a classic", code: "EVENT1", ageCategory: "12+", description: "Experience Shakespeare's masterpiece like never before", festival: "Edinburgh Fringe", festivalId: "FRINGE2025", genre: "Theatre", genreTags: "Drama, Classical", performances: [FringePerformance(title: "Evening Show", type: .inPerson, isAtFixedTime: true, priceType: .paid, price: 15.0, concession: 12.0, priceString: "£15 (£12)", start: Date().resetToSecond(), end: Date().addingTimeInterval(7200).resetToSecond(), durationMinutes: 120)], performanceSpace: .init(name: "Main Stage"), status: .active, url: URL(string: "https://fringe.co.uk/event1")!, venue: mockFringeVenue1, website: URL(string: "https://shakespearecompany.com")!, disabled: nil, images: ["main": FringeImage(hash: "abc123", orientation: .landscape, type: .hero, versions: ["original": .init(type: "original", width: 1920, height: 1080, mime: "image/jpeg", url: URL(string: "https://example.com/images/original.jpg")!)])], warnings: "Contains strobe lighting", updated: Date().resetToSecond(), year: 2025)
    private static let mockEvent2 = FringeEvent(title: "Comedy Night", artist: "Laugh Factory", country: "USA", descriptionTeaser: "Non-stop laughter guaranteed", code: "EVENT2", ageCategory: "18+", description: "Join us for an evening of stand-up comedy", festival: "Edinburgh Fringe", festivalId: "FRINGE2025", genre: "Comedy", genreTags: "Stand-up, Improv", performances: [FringePerformance(title: "Late Show", type: .inPerson, isAtFixedTime: true, priceType: .paid, price: 12.0, concession: 10.0, priceString: "£12 (£10)", start: Date().resetToSecond(), end: Date().addingTimeInterval(5400).resetToSecond(), durationMinutes: 90)], performanceSpace: .init(name: "Main Stage"), status: .active, url: URL(string: "https://fringe.co.uk/event2")!, venue: mockFringeVenue1, website: URL(string: "https://laughfactory.com")!, disabled: nil, images: ["main": FringeImage(hash: "def456", orientation: .portrait, type: .thumb, versions: ["thumb": .init(type: "thumb", width: 300, height: 400, mime: "image/jpeg", url: URL(string: "https://example.com/images/thumb.jpg")!)])], warnings: "Adult content", updated: Date().resetToSecond(), year: 2025)
    private static let mockEvent3 = FringeEvent(title: "Dance Fusion", artist: "Modern Dance Collective", country: "France", descriptionTeaser: "Contemporary dance meets traditional ballet", code: "EVENT3", ageCategory: "All ages", description: "A spectacular fusion of dance styles", festival: "Edinburgh Fringe", festivalId: "FRINGE2025", genre: "Dance", genreTags: "Contemporary, Ballet", performances: [FringePerformance(title: "Matinee", type: .inPerson, isAtFixedTime: true, priceType: .paid, price: 18.0, concession: 15.0, priceString: "£18 (£15)", start: Date().resetToSecond(), end: Date().addingTimeInterval(4500).resetToSecond(), durationMinutes: 75)], performanceSpace: .init(name: "Studio Space"), status: .active, url: URL(string: "https://fringe.co.uk/event3")!, venue: mockFringeVenue2, website: URL(string: "https://dancecollective.com")!, disabled: nil, images: ["main": FringeImage(hash: "ghi789", orientation: .square, type: .hero, versions: ["square": .init(type: "square", width: 800, height: 800, mime: "image/jpeg", url: URL(string: "https://example.com/images/square.jpg")!)])], warnings: nil, updated: Date().resetToSecond(), year: 2025)
    private static let mockFringePerformance = FringePerformance(title: "Mock Performance", type: .inPerson, isAtFixedTime: true, priceType: .paid, price: 20.0, concession: 15.0, priceString: "£20 (£15)", start: Date().resetToSecond(), end: Date().addingTimeInterval(7200).resetToSecond(), durationMinutes: 120)
    
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
        let apiModel = Self.mockFringeVenue1
        try await addModelToDB(apiModel, expecting: .insertedModel)
        
        // Test: There should now be one model in the database
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            #expect(venues.count == 1, "Venue should have been added")
            #expect(venues.first == apiModel, "Venue should have been added")
        }
    }
    
    @Test("Updates model if new content is available")
    func testUpdatesModelIfNewContentIsAvailable() async throws {
        // Setup environment
        let originalModel = Self.mockFringeVenue1
        let updatedModel = Self.mockFringeVenue3
        // Sanity Check
        try #require(originalModel != updatedModel, "Sanity Check: Models should be different")
        try #require(originalModel.code == updatedModel.code, "Sanity Check Models should share the same code value")
        
        // Add the first model to the database
        try await addModelToDB(originalModel, expecting: .insertedModel)
        // The model should now be in the database
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            #expect(venues.count == 1)
        }
        
        // Update the database with a model sharing the same code
        try await addModelToDB(updatedModel, expecting: .updatedModel)
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
        // Add models to DB, should be inserts as they are different models
        try await addModelToDB(Self.mockFringeVenue1, expecting: .insertedModel)
        try await addModelToDB(Self.mockFringeVenue2, expecting: .insertedModel)
        
        // Test: There should now be two models in the database
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            #expect(venues.count == 2, "There should be two models in the database")
            // Both codes should now be in the DB
            #expect(venues.contains { $0.code == Self.mockFringeVenue1.code })
            #expect(venues.contains { $0.code == Self.mockFringeVenue2.code })
        }
    }

    @Test("Returns noChanges if model already exists with the same data (Venue)")
    func testReturnsNoChangesIfModelAlreadyExistsWithSameData_Venue() async throws {
        // Adding a new model should result in an insert
        try await addModelToDB(Self.mockFringeVenue1, expecting: .insertedModel)
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            #expect(venues.count == 1, "There should be 1 model in the database")
        }
        
        // Adding the same model should result in noChanges
        try await addModelToDB(Self.mockFringeVenue1, expecting: .noChanges)
        try await testActor.performFetch(from: Self.allVenuesDescriptor) { venues in
            #expect(venues.count == 1, "There should still only be 1 modes in the database")
        }
    }
    
    @Test("Returns noChanges if model already exists with the same data (Event)")
    func testReturnsNoChangesIfModelAlreadyExistsWithSameData_Event() async throws {
        // Add venues so that relationships can be made for the event
        try await addModelToDB(Self.mockFringeVenue1, expecting: .insertedModel)
        
        // Adding a new model should result in an insert
        try await addModelToDB(Self.mockEvent1, expecting: .insertedModel)
        try await testActor.performFetch(from: Self.allEventsDescriptor) { events in
            #expect(events.count == 1, "There should be 1 model in the database")
        }
        
        // Adding the same model should result in noChanges
        try await addModelToDB(Self.mockEvent1, expecting: .noChanges)
        try await testActor.performFetch(from: Self.allEventsDescriptor) { events in
            #expect(events.count == 1, "There should still only be 1 modes in the database")
        }
    }
    
    @Test("Events insert if they do not exist")
    func testEventsInsertIfTheyDoNotExist() async throws {
        // Importing the events should insert 5 models
        let initialStatuses = try await importAPIActor.updateEvents([Self.mockEvent1, Self.mockEvent2, Self.mockEvent3])
        #expect(initialStatuses.count == 5, "5 (3 events & 2 venues) statuses should be returned: \(initialStatuses)")
        #expect(initialStatuses.count(where: { $0 == .insertedModel }) == 5, "All events should be inserts as they are new content")
    }
    
    @Test("Events do not insert or update if changes do not exist")
    func testEventsDoNotInsertOrUpdateIfChangesDoNotExist() async throws {
        // Importing the events should insert 5 models
        let initialStatuses = try await importAPIActor.updateEvents([Self.mockEvent1, Self.mockEvent2, Self.mockEvent3])
        #expect(initialStatuses.count == 5, "5 (3 events & 2 venues) statuses should be returned: \(initialStatuses)")
        #expect(initialStatuses.count(where: { $0 == .insertedModel }) == 5, "All events should be inserts as they are new content")
        
        // Attempting to re-import the events should make no changes
        let reimportedStatuses = try await importAPIActor.updateEvents([Self.mockEvent1, Self.mockEvent2, Self.mockEvent3])
        #expect(reimportedStatuses.count == 5, "5 noChanges statuses should be returned: \(reimportedStatuses)")
        #expect(reimportedStatuses.count(where: { $0 == .noChanges }) == 5, "Content already exists so does not require updating: \(reimportedStatuses)")
    }
    
    @Test("Events will update if changes are found")
    func testEventsWillUpdateIfChangesAreFound_Event() async throws {
        // Importing the events should insert 5 models
        let initialStatuses = try await importAPIActor.updateEvents([Self.mockEvent1, Self.mockEvent2, Self.mockEvent3])
        #expect(initialStatuses.count == 5, "5 (3 events & 2 venues) statuses should be returned: \(initialStatuses)")
        #expect(initialStatuses.count(where: { $0 == .insertedModel }) == 5, "All events should be inserts as they are new content")

        // Create a new event with a changed title
        let updatedMockEvent1 = FringeEvent(title: "Title Changed", artist: "Shakespeare Company", country: "United Kingdom", descriptionTeaser: "A modern take on a classic", code: "EVENT1", ageCategory: "12+", description: "Experience Shakespeare's masterpiece like never before", festival: "Edinburgh Fringe", festivalId: "FRINGE2025", genre: "Theatre", genreTags: "Drama, Classical", performances: [FringePerformance(title: "Evening Show", type: .inPerson, isAtFixedTime: true, priceType: .paid, price: 15.0, concession: 12.0, priceString: "£15 (£12)", start: Date().resetToSecond(), end: Date().addingTimeInterval(7200).resetToSecond(), durationMinutes: 120)], performanceSpace: .init(name: "Main Stage"), status: .active, url: URL(string: "https://fringe.co.uk/event1")!, venue: Self.mockFringeVenue1, website: URL(string: "https://shakespearecompany.com")!, disabled: nil, images: ["main": FringeImage(hash: "abc123", orientation: .landscape, type: .hero, versions: ["original": .init(type: "original", width: 1920, height: 1080, mime: "image/jpeg", url: URL(string: "https://example.com/images/original.jpg")!)])], warnings: "Contains strobe lighting", updated: Date().resetToSecond(), year: 2025)
        try #require(updatedMockEvent1 != Self.mockEvent1, "Sanity Check: Models should be different")
        try #require(updatedMockEvent1.title != Self.mockEvent1.title, "Sanity Check: Models should be different")
        try #require(updatedMockEvent1.code == Self.mockEvent1.code, "Sanity Check: Models should share the same code value")

        // Update the event in the database
        let updatedStatuses = try await importAPIActor.updateEvents([updatedMockEvent1, Self.mockEvent2, Self.mockEvent3])
        #expect(updatedStatuses.count == 5, "5 (3 events & 2 venues) statuses should be returned: \(updatedStatuses)")
        #expect(updatedStatuses.count(where: { $0 == .updatedModel }) == 1, "Only the first event should have been updated")
        try await importAPIActor.saveChanges()
        
        // Changes should now have been made
        try await testActor.performFetch(from: FetchDescriptor<DBFringeEvent>(predicate: #Predicate { $0.code == updatedMockEvent1.code })) { events in
            try #require(events.count == 1, "There should still only be 1 modes in the database")
            let event = try #require(events.first)
            #expect(event.title == updatedMockEvent1.title, "Title should have been updated")
        }
    }
    
    @Test("Venues will update if changes are found")
    func testVenuesWillUpdateIfChangesAreFound_Venue() async throws {
        // Importing the events should insert 5 models
        let initialStatuses = try await importAPIActor.updateEvents([Self.mockEvent1, Self.mockEvent2, Self.mockEvent3])
        #expect(initialStatuses.count == 5, "5 (3 events & 2 venues) statuses should be returned: \(initialStatuses)")
        #expect(initialStatuses.count(where: { $0 == .insertedModel }) == 5, "All events should be inserts as they are new content")

        // Create a new event a venue that has a changed name
        let updatedMockVenue2 = FringeVenue(code: "VENUE2", description: nil, name: "Updated NAME", address: "456 Example Ave", position: .init(lat: 55.9533, lon: -3.1883), postCode: "67890", webAddress: nil, phone: nil, email: nil, disabledDescription: nil)
        let updatedMockEvent3 = FringeEvent(title: "Dance Fusion", artist: "Modern Dance Collective", country: "France", descriptionTeaser: "Contemporary dance meets traditional ballet", code: "EVENT3", ageCategory: "All ages", description: "A spectacular fusion of dance styles", festival: "Edinburgh Fringe", festivalId: "FRINGE2025", genre: "Dance", genreTags: "Contemporary, Ballet", performances: [FringePerformance(title: "Matinee", type: .inPerson, isAtFixedTime: true, priceType: .paid, price: 18.0, concession: 15.0, priceString: "£18 (£15)", start: Date().resetToSecond(), end: Date().addingTimeInterval(4500).resetToSecond(), durationMinutes: 75)], performanceSpace: .init(name: "Studio Space"), status: .active, url: URL(string: "https://fringe.co.uk/event3")!, venue: updatedMockVenue2, website: URL(string: "https://dancecollective.com")!, disabled: nil, images: ["main": FringeImage(hash: "ghi789", orientation: .square, type: .hero, versions: ["square": .init(type: "square", width: 800, height: 800, mime: "image/jpeg", url: URL(string: "https://example.com/images/square.jpg")!)])], warnings: nil, updated: Date().resetToSecond(), year: 2025)
        try #require(updatedMockVenue2 != Self.mockFringeVenue2, "Sanity Check: Models should be different")
        try #require(updatedMockVenue2.name != Self.mockFringeVenue2.name, "Sanity Check: Models should be different")
        try #require(updatedMockVenue2.code == Self.mockFringeVenue2.code, "Sanity Check: Models should share the same code value")
        try #require(updatedMockEvent3.code == Self.mockEvent3.code, "Sanity Check: Models should share the same code value")

        // Update the event in the database
        let updatedStatuses = try await importAPIActor.updateEvents([Self.mockEvent1, Self.mockEvent2, updatedMockEvent3])
        #expect(updatedStatuses.count == 5, "5 (3 events & 2 venues) statuses should be returned: \(updatedStatuses)")
        #expect(updatedStatuses.count(where: { $0 == .updatedModel }) == 1, "Only the first event should have been updated")
        try await importAPIActor.saveChanges()
        
        // Changes should now have been made
        try await testActor.performFetch(from: FetchDescriptor<DBFringeVenue>(predicate: #Predicate { $0.code == updatedMockVenue2.code })) { venues in
            try #require(venues.count == 1, "There should still only be 1 modes in the database")
            let venue = try #require(venues.first)
            #expect(venue.name == updatedMockVenue2.name, "Name should have been updated")
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
            
            #expect(try await insertActor.insertModel(from: DBFringeVenue.apiModel) == .insertedModel)
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
