//
//  SwiftDataUpdatedFieldTest.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/02/2025.
//

import Testing
import Foundation
import SwiftData

extension ExpectedIssues {
    /// For some reason, using the `updated` field in SwiftData will cause the value to not be returned.
    /// This test validates this suspicion
    @Test("SwiftData does not handle the `updated` field correctly")
    func testUpdatedFieldIsLost() async throws {
        // Setup Container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TestModel.self, configurations: config)
        let dbActor = BasicDBActor(modelContainer: container)
        
        // Create model
        let date = try #require(DateComponents(calendar: Calendar.current, year: 2024, month: 9, day: 11, hour: 13, minute: 39, second: 35).date)
        let model = TestModel(title: "test value", updated: date, otherDate: date)
        
        // Add model to DB
        try await dbActor.insert(model)
        
        // Verify changes
        try await dbActor.performFetch(from: FetchDescriptor<TestModel>()) { models in
            try #require(models.count == 1, "Only one model should exist")
            let model = try #require(models.first)
            
            // Test values
            #expect(model.title == "test value")
            #expect(model.updated != date, "The `updated` field should fail returning the correct value in SwiftData")
            #expect(model.otherDate == date, "This date field is not used in SwiftData so should return correctly")
        }
    }
    
    // MARK: Classes / Actors
    
    @Model
    fileprivate class TestModel {
        var title: String
        var updated: Date
        var otherDate: Date
        
        init(title: String, updated: Date, otherDate: Date) {
            self.title = title
            self.updated = updated
            self.otherDate = otherDate
        }
    }
    
    @ModelActor
    fileprivate actor BasicDBActor {
        func insert<T: PersistentModel>(_ model: T) throws {
            self.modelContext.insert(model)
            try self.modelContext.save()
        }
        
        func performFetch<T: PersistentModel>(from descriptor: FetchDescriptor<T>, _ check: (([T]) throws -> Void)) throws {
            let existingModels = try modelContext.fetch(descriptor)
            try check(existingModels)
        }
    }
}

// MARK: -

/// An umbrella term for things that should not be an issue but are, and cannot be resolved.
/// - Note: Having a test for these allows us to identify if things are fixed in different SDKs
@Suite("Expected Issues")
struct ExpectedIssues {}
