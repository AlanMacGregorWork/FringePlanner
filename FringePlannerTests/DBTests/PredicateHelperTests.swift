//
//  PredicateHelperTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 12/05/2025.
//

import SwiftData
import Foundation
import Testing
@testable import FringePlanner

@Suite("PredicateHelper Tests")
struct PredicateHelperTests {
    
    @Test("Event function returns matching event from event code")
    func testEventFunctionReturnsMatchingEventFromEventCode() async throws {
        // Setup environment
        // Setup database
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DBFringeEvent.self, DBFringeVenue.self, configurations: config)
        let context = ModelContext(container)
        // Setup test data
        let event1 = SeededContent().event(config: .init(code: .override("event1")))
        let event2 = SeededContent().event(config: .init(code: .override("event2")))
        try #require(event1 != event2, "Sanity Check: Events should be different")
        // Add data to database
        let actor = ImportAPIActor(modelContainer: container)
        try await actor.updateEvents([event1, event2])
        
        // Test: With matching event codes
        #expect(try PredicateHelper.event(eventCode: "event1").getContent(context: context) == event1)
        #expect(try PredicateHelper.event(eventCode: "event2").getContent(context: context) == event2)
        
        // Test: With non-matching event codes
        #expect((try? PredicateHelper.event(eventCode: "event3").getContent(context: context)) == nil)
    }
    
    @Test("Performance function returns matching performance from referenceID")
    func testPerformanceFunctionReturnsMatchingPerformanceFromReferenceID() async throws {
        // Setup environment
        // Setup database
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DBFringeEvent.self, DBFringeVenue.self, DBFringePerformance.self, configurations: config)
        let context = ModelContext(container)
        // Setup test data
        let event = SeededContent().event(config: .init(code: .override("event-code-here")))
        let performance1 = event.performances[0]
        let performance2 = event.performances[1]
        try #require(performance1 != performance2, "Sanity Check: Performances should be different")
        // Add data to database
        let actor = ImportAPIActor(modelContainer: container)
        try await actor.updateEvents([event])

        // Test: With matching reference IDs    
        #expect(try PredicateHelper.performance(referenceID: performance1.referenceID).getContent(context: context) == performance1)
        #expect(try PredicateHelper.performance(referenceID: performance2.referenceID).getContent(context: context) == performance2)

        // Test: With non-matching reference ID
        #expect((try? PredicateHelper.performance(referenceID: "nonExistentRefID").getContent(context: context)) == nil)
    }
}
