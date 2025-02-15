//
//  DBFringeEventTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 11/01/2025.
//

import Foundation
import Testing
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
        let mockStart = Date()
        let mockEnd = Date()
        let mockPerformance = FringePerformance(title: "Test Performance", type: .inPerson, isAtFixedTime: true, priceType: .paid, price: 15.0, concession: 12.0, priceString: "£15", start: mockStart, end: mockEnd, durationMinutes: 60, eventCode: "blank")
        let mockPosition = FringeVenue.Position(lat: 55.9486, lon: -3.1999)
        let mockVenue = FringeVenue(code: "VEN123", description: "Test Venue", name: "Test Venue", address: "123 Test St", position: mockPosition, postCode: "EH1 1AB", webAddress: URL(string: "https://test.com"), phone: "12345", email: "test@test.com", disabledDescription: "Accessible")
        let mockPerformanceSpace = FringePerformanceSpace(name: "Main Stage")
        let mockAPIModel = FringeEvent(title: "Mock Event", artist: "Test Artist", country: "UK", descriptionTeaser: "A teaser", code: "EVT123", ageCategory: "12+", description: "A test event", festival: "Edinburgh Fringe", festivalId: "F2025", genre: "Comedy", genreTags: "stand-up,comedy", performances: [mockPerformance], performanceSpace: mockPerformanceSpace, status: .active, url: URL(string: "https://test.com")!, venue: mockVenue, website: URL(string: "https://test.com")!, disabled: nil, images: [:], warnings: nil, updated: mockStart, year: 2025)
        let mockDBModel1 = DBFringeEvent(title: "Mock Event", artist: "Test Artist", country: "UK", descriptionTeaser: "Different teaser", code: "EVT123", ageCategory: "12+", eventDescription: "Different description", festival: "Edinburgh Fringe", festivalId: "F2025", genre: "Comedy", genreTags: "stand-up,comedy", performances: [mockPerformance], performanceSpace: mockPerformanceSpace, status: .active, url: URL(string: "https://test.com")!, venue: DBFringeVenue(code: mockVenue.code, name: mockVenue.name, position: mockVenue.position, postCode: mockVenue.postCode), website: URL(string: "https://test.com")!, disabled: nil, images: [:], warnings: nil, updatedValue: mockStart, year: 2025)
        let mockDBModel2 = DBFringeEvent(title: "Different Event", artist: "Other Artist", country: "USA", descriptionTeaser: "Another teaser", code: "EVT456", ageCategory: "18+", eventDescription: "Another test event", festival: "Edinburgh Fringe", festivalId: "F2025", genre: "Theatre", genreTags: "drama,theatre", performances: [mockPerformance], performanceSpace: mockPerformanceSpace, status: .active, url: URL(string: "https://test2.com")!, venue: DBFringeVenue(code: "VEN456", name: "Another Venue", position: mockPosition, postCode: "EH2 2AB"), website: URL(string: "https://test2.com")!, disabled: nil, images: [:], warnings: nil, updatedValue: mockEnd, year: 2025)

        // Verify content. DB models should not equate to API model but the DB model `code` should match the API model `code`
        try #require(mockAPIModel != mockDBModel1, "DB & API models should not match")
        try #require(mockAPIModel != mockDBModel2, "DB & API models should not match")
        try #require(mockAPIModel.code == mockDBModel1.code, "DB model #1 code should match API model code")
        try #require(mockAPIModel.code != mockDBModel2.code, "DB model #2 code should not match API model code")

        try autoTestPredicateIdentifiesCorrectModels(mockAPIModel: mockAPIModel, mockDBModel1: mockDBModel1, mockDBModel2: mockDBModel2)
    }
}
