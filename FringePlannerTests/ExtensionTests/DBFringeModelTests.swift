//
//  DBFringeModelTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/01/2025.
//

import Testing
import Foundation
@testable import FringePlanner

@Suite("DBFringeModel Tests")
struct DBFringeModelTests {
 
    @Suite("Equatable from APIFringeModel")
    struct EquatableFromAPIFringeModel {
        let mockDBFringeVenue1 = DBFringeVenue(code: "V001", venueDescription: "A great venue", name: "Venue One", address: "123 Main St", position: .init(lat: 55.9533, lon: -3.1883), postCode: "EH1 1AA", webAddress: URL(string: "http://venueone.com"), phone: "123-456-7890", email: "contact@venueone.com", disabledDescription: "Wheelchair accessible")
        let mockDBFringeVenue2 = DBFringeVenue(code: "V002", venueDescription: "Another great venue", name: "Venue Two", address: "456 Side St", position: .init(lat: 55.9534, lon: -3.1884), postCode: "EH1 1AB", webAddress: URL(string: "http://venuetwo.com"), phone: "098-765-4321", email: "contact@venuetwo.com", disabledDescription: "Not wheelchair accessible")
        let mockFringeVenue1 = FringeVenue(code: "V001", description: "A great venue", name: "Venue One", address: "123 Main St", position: .init(lat: 55.9533, lon: -3.1883), postCode: "EH1 1AA", webAddress: URL(string: "http://venueone.com"), phone: "123-456-7890", email: "contact@venueone.com", disabledDescription: "Wheelchair accessible")
        let mockFringeVenue2 = FringeVenue(code: "V002", description: "Another great venue", name: "Venue Two", address: "456 Side St", position: .init(lat: 55.9534, lon: -3.1884), postCode: "EH1 1AB", webAddress: URL(string: "http://venuetwo.com"), phone: "098-765-4321", email: "contact@venuetwo.com", disabledDescription: "Not wheelchair accessible")
        
        @Test("Correctly uses `==`")
        func testCorrectlyPassesEquate() throws {
            // Sanity Check
            try #require(mockDBFringeVenue1 == mockDBFringeVenue1, "Equating DB with itself should always be true")
            try #require(mockFringeVenue1 == mockFringeVenue1, "Equating API with itself should always be true")

            // Test
            #expect(mockDBFringeVenue1 == mockFringeVenue1, "DB & API Models should be equatable due to their equal properties")
            #expect(mockFringeVenue1 == mockDBFringeVenue1, "DB & API Models should be equatable due to their equal properties")
        }

        @Test("Correct uses `!=`")
        func testCorrectlyPassesInEquate() throws {
            // Sanity Check
            try #require(mockDBFringeVenue1 != mockDBFringeVenue2, "DB Models with different properties should not be equal")
            try #require(mockFringeVenue1 != mockFringeVenue2, "API Models with different properties should not be equal")

            // Test
            #expect(mockDBFringeVenue1 != mockFringeVenue2, "DB & API Models have different properties so should not be equal")
            #expect(mockFringeVenue1 != mockDBFringeVenue2, "DB & API Models have different properties so should not be equal")
        }
        
        @Test("Correctly handles optional models")
        func testCorrectlyHandlesOptionals() throws {
            // Test optional DB model
            #expect((nil as DBFringeVenue?) != mockFringeVenue1, "Models should not equate if only one is nil")
            #expect(mockFringeVenue1 != (nil as DBFringeVenue?), "Models should not equate if only one is nil")
            #expect((mockDBFringeVenue1 as DBFringeVenue?) == mockFringeVenue1, "Both models should equate")
            #expect(mockFringeVenue1 == (mockDBFringeVenue1 as DBFringeVenue?), "Both models should equate")

            // Test optional API model
            #expect((nil as FringeVenue?) != mockDBFringeVenue1, "Models should not equate if only one is nil")
            #expect(mockDBFringeVenue1 != (nil as FringeVenue?), "Models should not equate if only one is nil")
            #expect((mockFringeVenue1 as FringeVenue?) == mockDBFringeVenue1, "Both models should equate")
            #expect(mockDBFringeVenue1 == (mockFringeVenue1 as FringeVenue?), "Both models should equate")

            // Test both nil
            #expect((nil as FringeVenue?) == (nil as DBFringeVenue?), "Both nil models should equate")
            #expect((nil as DBFringeVenue?) == (nil as FringeVenue?), "Both nil models should equate")

            // Test matching values
            #expect(mockDBFringeVenue1 as DBFringeVenue? == mockFringeVenue1 as FringeVenue?, "Both models are non-optional, and should equate on their values")
            #expect(mockFringeVenue1 as FringeVenue? == mockDBFringeVenue1 as DBFringeVenue?, "Both models are non-optional, and should equate on their values")
            #expect(!(mockDBFringeVenue1 as DBFringeVenue? != mockFringeVenue1 as FringeVenue?), "Both models are non-optional, and should not not-equate on their values")
            #expect(!(mockFringeVenue1 as FringeVenue? != mockDBFringeVenue1 as DBFringeVenue?), "Both models are non-optional, and should not not-equate on their values")

            // Test non-matching values
            #expect(mockDBFringeVenue1 as DBFringeVenue? != mockFringeVenue2 as FringeVenue?, "Both models are non-optional, but should not equate on their values")
            #expect(mockFringeVenue2 as FringeVenue? != mockDBFringeVenue1 as DBFringeVenue?, "Both models are non-optional, but should not equate on their values")
            #expect(!(mockDBFringeVenue1 as DBFringeVenue? == mockFringeVenue2 as FringeVenue?), "Both models are non-optional, but should not equate on their values")
            #expect(!(mockFringeVenue2 as FringeVenue? == mockDBFringeVenue1 as DBFringeVenue?), "Both models are non-optional, but should not equate on their values")
        }
    }
}
    
