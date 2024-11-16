//
//  FilterRequestTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 31/10/2024.
//

import Foundation
import Testing
@testable import FringePlanner

@Suite("FilterRequest Tests")
struct FilterRequestTests {
        
    // MARK: Tests
        
    @Test("Verify dictionary used for testing matches actual data")
    func verifyTestDictionary() throws {
        // Get Keys
        let request = FilterRequest()
        let mirrorRequest = Mirror(reflecting: request)
        let childrenKeys = mirrorRequest.children.compactMap(\.label).sorted()
        
        // Identify missing keys
        let missingChildrenKeys = filterChecks.map(\.key).filter({ !childrenKeys.contains($0) })
        let missingDictionaryKeys = childrenKeys.filter({ !filterChecks.map(\.key).contains($0) })
        #expect(missingChildrenKeys.isEmpty, "Dictionary has models to remove: \(missingChildrenKeys.joined(separator: ", "))")
        #expect(missingDictionaryKeys.isEmpty, "Dictionary is missing values: \(missingDictionaryKeys.joined(separator: ", "))")
        
        // Expected names should be unique
        try #require(Set(filterChecks.values.map(\.expectedName)).count == filterChecks.count, "Dictionary expectedNames are not unique")
    }

    @Test("Verify basic query items", arguments: filterChecks.keys)
    func verifyQueryItems(_ key: String) throws {
        let check = try #require(filterChecks[key], "Key `\(key)` is not found")
        let request = check.request
        let mirrorRequest = Mirror(reflecting: request)
        try #require(mirrorRequest.children.compactMap({ $0 }).contains(where: { $0.label == key }), "Should have test content")
        #expect(check.request.queryItem == [URLQueryItem(name: check.expectedName, value: check.expectedValue)], "KShould be \([URLQueryItem(name: check.expectedName, value: check.expectedValue)]), but is: \(check.request.queryItem)")
    }
    
    // MARK: Specific Tests
    
    @Suite("Specific Tests")
    struct SpecificTests {
        
        // MARK: Properties
        
        private static let boolKeyPaths: [String: WritableKeyPath<FilterRequest, Bool?>] = [
            "hasAudioDescription": \.hasAudioDescription,
            "hasCaptioning": \.hasCaptioning,
            "hasSigned": \.hasSigned,
            "hasOtherAccessibility": \.hasOtherAccessibility,
            "prettyPrint": \.prettyPrint
        ]
        
        static let stringKeyPaths: [String: WritableKeyPath<FilterRequest, String?>] = [
            "artist": \.artist,
            "description": \.description,
            "title": \.title,
            "venueName": \.venueName,
            "venueCode": \.venueCode,
            "postCode": \.postCode
        ]
        
        // MARK: Tests
        
        @Test("Bool values should only be present when true", arguments: Self.boolKeyPaths.keys)
        func boolValuesShouldOnlyBePresentWhenTrue(_ key: String) throws {
            let keyPath = try #require(Self.boolKeyPaths[key])
            var filterRequest = FilterRequest()
            
            // Should not return
            filterRequest[keyPath: keyPath] = false
            #expect(filterRequest.queryItem.isEmpty)
            filterRequest[keyPath: keyPath] = nil
            #expect(filterRequest.queryItem.isEmpty)
            // Should return
            filterRequest[keyPath: keyPath] = true
            #expect(filterRequest.queryItem.count == 1)
            #expect(filterRequest.queryItem.first?.value == "1")
        }
        
        @Test("String values should only be present when not empty", arguments: Self.stringKeyPaths.keys)
        func stringValuesShouldOnlyBePresentWhenTrue(_ key: String) throws {
            let keyPath = try #require(Self.stringKeyPaths[key])
            var filterRequest = FilterRequest()
            
            // Should not return
            filterRequest[keyPath: keyPath] = ""
            #expect(filterRequest.queryItem.isEmpty)
            filterRequest[keyPath: keyPath] = "      "
            #expect(filterRequest.queryItem.isEmpty)
            // Should return
            filterRequest[keyPath: keyPath] = "someText"
            #expect(filterRequest.queryItem.count == 1)
            #expect(filterRequest.queryItem.first?.value == "someText")
            filterRequest[keyPath: keyPath] = "   someText     "
            #expect(filterRequest.queryItem.count == 1)
            #expect(filterRequest.queryItem.first?.value == "someText")
        }
        
        @Test("Price values are in range")
        func priceValuesInRange() {
            #expect(FilterRequest(priceFrom: -12).queryItem == [], "Prices must be more than 0")
            #expect(FilterRequest(priceFrom: 0).queryItem == [], "Prices must be more than 0")
            #expect(FilterRequest(priceFrom: 1).queryItem == [URLQueryItem(name: "price_from", value: "1")], "Prices must be more than 0")
            #expect(FilterRequest(priceTo: -12).queryItem == [], "Prices must be more than 0")
            #expect(FilterRequest(priceTo: 0).queryItem == [], "Prices must be more than 0")
            #expect(FilterRequest(priceTo: 1).queryItem == [URLQueryItem(name: "price_to", value: "1")], "Prices must be more than 0")
            #expect(FilterRequest(priceFrom: 20, priceTo: 30).queryItem == [URLQueryItem(name: "price_from", value: "20"), URLQueryItem(name: "price_to", value: "30")], "Prices should have a valid range")
            #expect(FilterRequest(priceFrom: 30, priceTo: 20).queryItem == [], "Invalid ranges should not include either value as there is no way to identify which to use")
            #expect(FilterRequest(priceFrom: 30, priceTo: 30).queryItem == [URLQueryItem(name: "price_from", value: "30"), URLQueryItem(name: "price_to", value: "30")], "Same values are valid")
        }
        
        @Test("Date values are in range")
        func dateValuesInRange() {
            let dateEarlier = DateComponents(calendar: Calendar.current, year: 2024, month: 4, day: 5, hour: 17, minute: 45, second: 43).date!
            let dateLater = DateComponents(calendar: Calendar.current, year: 2025, month: 4, day: 5, hour: 17, minute: 45, second: 43).date!
            #expect(FilterRequest(dateFrom: dateEarlier).queryItem == [URLQueryItem(name: "date_from", value: "2024-04-05 17:45:43")], "Should create query with another date value")
            #expect(FilterRequest(dateTo: dateEarlier).queryItem == [URLQueryItem(name: "date_to", value: "2024-04-05 17:45:43")], "Should create query with another date value")
            #expect(FilterRequest(dateFrom: dateLater, dateTo: dateEarlier).queryItem.isEmpty, "Range should be in order")
            #expect(FilterRequest(dateFrom: dateEarlier, dateTo: dateLater).queryItem == [URLQueryItem(name: "date_from", value: "2024-04-05 17:45:43"), URLQueryItem(name: "date_to", value: "2025-04-05 17:45:43")], "Range should be in order")
            #expect(FilterRequest(dateFrom: dateEarlier, dateTo: dateEarlier).queryItem == [URLQueryItem(name: "date_from", value: "2024-04-05 17:45:43"), URLQueryItem(name: "date_to", value: "2024-04-05 17:45:43")], "Matching values are valid")
        }
        
        @Test("Page size is in range")
        func pageSizeIsInRange() {
            #expect(FilterRequest(pageSize: nil).queryItem == [], "If value is nil, nothing should return")
            #expect(FilterRequest(pageSize: 24).queryItem == [URLQueryItem(name: "size", value: "25")], "Minimum value should be 25")
            #expect(FilterRequest(pageSize: 25).queryItem == [URLQueryItem(name: "size", value: "25")], "Minimum value should be 25")
            #expect(FilterRequest(pageSize: 100).queryItem == [URLQueryItem(name: "size", value: "100")], "Maximum value should be 100")
            #expect(FilterRequest(pageSize: 101).queryItem == [URLQueryItem(name: "size", value: "100")], "Maximum value should be 100")
        }
        
        @Test("From page is in range")
        func pageFromMustBePositive() {
            #expect(FilterRequest(fromPage: nil).queryItem == [], "If value is nil, nothing should return")
            #expect(FilterRequest(fromPage: 0).queryItem == [], "If value is less than 1, nothing should return")
            #expect(FilterRequest(fromPage: -1).queryItem == [], "If value is less than 1, nothing should return")
            #expect(FilterRequest(fromPage: 1).queryItem == [URLQueryItem(name: "from", value: "1")], "If value is more than 0, value should return")
            #expect(FilterRequest(fromPage: 56).queryItem == [URLQueryItem(name: "from", value: "56")], "If value is more than 0, values should return")
        }
    }
}

// MARK: Helpers

struct FilterRequestCheck {
    let request: FilterRequest
    let expectedName: String
    let expectedValue: String
}

private var filterChecks: [String: FilterRequestCheck] {
    let testDate = DateComponents(calendar: Calendar.current, year: 2024, month: 4, day: 5, hour: 17, minute: 45, second: 43).date!
    
    return [
        "dateFrom": .init(request: FilterRequest(dateFrom: testDate), expectedName: "date_from", expectedValue: "2024-04-05 17:45:43"),
        "dateTo": .init(request: FilterRequest(dateTo: testDate), expectedName: "date_to", expectedValue: "2024-04-05 17:45:43"),
        "artist": .init(request: FilterRequest(artist: "someArtistData"), expectedName: "artist", expectedValue: "someArtistData"),
        "description": .init(request: FilterRequest(description: "someDescription"), expectedName: "description", expectedValue: "someDescription"),
        "title": .init(request: FilterRequest(title: "someTitle"), expectedName: "title", expectedValue: "someTitle"),
        "priceFrom": .init(request: FilterRequest(priceFrom: 100), expectedName: "price_from", expectedValue: "100"),
        "priceTo": .init(request: FilterRequest(priceTo: 200), expectedName: "price_to", expectedValue: "200"),
        "hasAudioDescription": .init(request: FilterRequest(hasAudioDescription: true), expectedName: "has_audio_description", expectedValue: "1"),
        "hasCaptioning": .init(request: FilterRequest(hasCaptioning: true), expectedName: "has_captioning", expectedValue: "1"),
        "hasSigned": .init(request: FilterRequest(hasSigned: true), expectedName: "has_signed", expectedValue: "1"),
        "hasOtherAccessibility": .init(request: FilterRequest(hasOtherAccessibility: true), expectedName: "has_other_accessibility", expectedValue: "1"),
        "venueName": .init(request: FilterRequest(venueName: "Sample Venue"), expectedName: "venue_name", expectedValue: "Sample Venue"),
        "venueCode": .init(request: FilterRequest(venueCode: "V123"), expectedName: "venue_code", expectedValue: "V123"),
        "postCode": .init(request: FilterRequest(postCode: "12345"), expectedName: "post_code", expectedValue: "12345"),
        "latitude": .init(request: FilterRequest(latitude: 51.5074), expectedName: "lat", expectedValue: "51.5074"),
        "longitude": .init(request: FilterRequest(longitude: -0.1278), expectedName: "lon", expectedValue: "-0.1278"),
        "pageSize": .init(request: FilterRequest(pageSize: 45), expectedName: "size", expectedValue: "45"),
        "fromPage": .init(request: FilterRequest(fromPage: 2), expectedName: "from", expectedValue: "2"),
        "prettyPrint": .init(request: FilterRequest(prettyPrint: true), expectedName: "pretty", expectedValue: "1")
    ]
}
