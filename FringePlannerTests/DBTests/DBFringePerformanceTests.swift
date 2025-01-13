//
//  DBFringePerformanceTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/12/2024.
//

import Foundation
import Testing
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

    @Test("Predicate identifies correct models")
    func testPredicateIdentifiesCorrectModels() throws {
        let mockStart = Date()
        let mockEnd = Date()
        let mockAPIModel = FringePerformance(title: "Mock Performance", type: .inPerson, isAtFixedTime: false, priceType: .paid, price: 10.0, concession: 5.0, priceString: "£10", start: mockStart, end: mockEnd, durationMinutes: 60)
        let mockDBModel1 = DBFringePerformance(title: "Different Performance", type: .inPerson, isAtFixedTime: false, priceType: .paid, price: 10.0, concession: 5.0, priceString: "£10", start: mockStart, end: mockEnd, durationMinutes: 60)
        let mockDBModel2 = DBFringePerformance(title: "Mock Performance 2", type: .inPerson, isAtFixedTime: false, priceType: .paid, price: 10.0, concession: 5.0, priceString: "£10", start: Date(), end: mockEnd, durationMinutes: 60)

        // Verify content. DB models should not equate to API model but the DB model `start` should match the API model `start`
        try #require(mockAPIModel != mockDBModel1, "DB & API models should not match")
        try #require(mockAPIModel != mockDBModel2, "DB & API models should not match")
        try #require(mockAPIModel.start == mockDBModel1.start, "DB model #1 start should match API model start")
        try #require(mockAPIModel.start != mockDBModel2.start, "DB model #2 start should not match API model start")
        
        try autoTestPredicateIdentifiesCorrectModels(mockAPIModel: mockAPIModel, mockDBModel1: mockDBModel1, mockDBModel2: mockDBModel2)
    }
}
