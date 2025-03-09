//
//  DBFringePerformanceTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/12/2024.
//

import Foundation
import Testing
import SwiftData
@testable import FringePlanner

@Suite("DBFringePerformance Tests")
class DBFringePerformanceTests: DBFringeModelTestProtocol {
    typealias DBModelType = DBFringePerformance
    
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
        // Setup Database
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DBFringeEvent.self, DBFringeVenue.self, DBFringePerformance.self, configurations: config)
        let context = ModelContext(container)
        // Create the API model
        let apiPerformance = SeededContent().performance(eventCode: "EVENT1", config: .init(type: .override(.inPerson)))
        let apiEvent = SeededContent().event(config: .init(code: .override("EVENT1"), performances: .override([apiPerformance])))
        
        let apiOtherEvent = SeededContent().event(config: .init(code: .override("EVENT2"), performances: .override([apiPerformance])))
        // Insert the venue and the event so that the relationships can be carried out.
        context.insert(try DBFringeVenue(apiModel: apiEvent.venue, context: context))
        context.insert(try DBFringeEvent(apiModel: apiEvent, context: context))
        context.insert(try DBFringeVenue(apiModel: apiOtherEvent.venue, context: context))
        context.insert(try DBFringeEvent(apiModel: apiOtherEvent, context: context))
        // Create the DB Models
        let apiAllValuesCorrect = SeededContent().performance(eventCode: "EVENT1", config: .init(start: .override(apiPerformance.start), type: .override(.onlineLive)))
        let apiEventCorrect = SeededContent().performance(eventCode: "EVENT1", config: .init(start: .override(apiPerformance.end)))
        let apiStartCorrect = SeededContent().performance(eventCode: "EVENT2", config: .init(start: .override(apiPerformance.start)))
        let dbAllValuesCorrect = try DBFringePerformance(apiModel: apiAllValuesCorrect, context: context)
        let dbEventCorrect = try DBFringePerformance(apiModel: apiEventCorrect, context: context)
        let dbStartCorrect = try DBFringePerformance(apiModel: apiStartCorrect, context: context)
        
        // Verify content. DB models should not equate to API model but the DB model `start` & `eventCode` should match the API model `start` & `eventCode  `
        try #require(apiPerformance != dbAllValuesCorrect, "DB & API models should not match")
        try #require(apiPerformance != dbEventCorrect, "DB & API models should not match")
        try #require(apiPerformance != dbStartCorrect, "DB & API models should not match")
        try #require(apiPerformance.start == dbAllValuesCorrect.start && apiPerformance.eventCode == dbAllValuesCorrect.eventCode, "Model matches start & event code")
        try #require(apiPerformance.start != dbEventCorrect.start && apiPerformance.eventCode == dbEventCorrect.eventCode, "Model only matches event code")
        try #require(apiPerformance.start == dbStartCorrect.start && apiPerformance.eventCode != dbStartCorrect.eventCode, "Model only matches start")
                                                                 
        // Only `dbAllValuesCorrect` should match the API model
        try autoTestPredicateIdentifiesCorrectModels(mockAPIModel: apiPerformance, mockDBModel1: dbAllValuesCorrect, mockDBModel2: dbEventCorrect)
        try autoTestPredicateIdentifiesCorrectModels(mockAPIModel: apiPerformance, mockDBModel1: dbAllValuesCorrect, mockDBModel2: dbStartCorrect)
    }
}
