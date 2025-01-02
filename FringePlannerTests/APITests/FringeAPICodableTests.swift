//
//  FringeAPICodableTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 31/12/2024.
//

import Testing
import Foundation
@testable import FringePlanner

@Suite("Fringe API Codable Tests")
struct FringeAPICodableTests {
    @Test("FringePerformanceType")
    func testFringePerformanceType() throws {
        try testEncodeDecodeEquates(value: FringePerformanceType.inPerson)
        try testEncodeDecodeEquates(value: FringePerformanceType.onlineLive)
        try testEncodeDecodeEquates(value: FringePerformanceType.onlineOnDemand)
        try testEncodeDecodeEquates(value: FringePerformanceType.other("some alternative value"))
    }
    
    @Test("FringePriceType")
    func testFringePriceType() throws {
        try testEncodeDecodeEquates(value: FringePriceType.paid)
        try testEncodeDecodeEquates(value: FringePriceType.free)
        try testEncodeDecodeEquates(value: FringePriceType.payWhatYouCan)
        try testEncodeDecodeEquates(value: FringePriceType.other("custom price type"))
    }
    
    @Test("FringeStatus")
    func testFringeStatus() throws {
        try testEncodeDecodeEquates(value: FringeStatus.active)
        try testEncodeDecodeEquates(value: FringeStatus.cancelled)
        try testEncodeDecodeEquates(value: FringeStatus.deleted)
    }
    
    @Test("FringeDisabled")
    func testFringeDisabled() throws {
        try testEncodeDecodeEquates(value: FringeDisabled(otherServices: nil, audio: nil, captioningDates: nil, signedDates: nil))
        try testEncodeDecodeEquates(value: FringeDisabled(otherServices: true, audio: false, captioningDates: [], signedDates: []))
        try testEncodeDecodeEquates(value: FringeDisabled(otherServices: false, audio: true, captioningDates: ["item1", "item2"], signedDates: ["valueA", "valueB"]))
    }
    
    @Test("FringePerformanceSpace")
    func testFringePerformanceSpace() throws {
        try testEncodeDecodeEquates(value: FringePerformanceSpace(name: "Item"))
        try testEncodeDecodeEquates(value: FringePerformanceSpace(name: "New"))
    }

    @Test("FringeVenue")
    func testFringeVenue() throws {
        try testEncodeDecodeEquates(value: FringeVenue(code: "VENUE1", description: nil, name: "Test Venue", address: nil, position: .init(lat: 55.9533, lon: -3.1883), postCode: "EH1 1QS", webAddress: nil, phone: nil, email: nil, disabledDescription: nil))
        try testEncodeDecodeEquates(value: FringeVenue(code: "VENUE2", description: "A lovely venue", name: "Edinburgh Playhouse", address: "18-22 Greenside Place", position: .init(lat: 55.9571, lon: -3.1856), postCode: "EH1 3AA", webAddress: URL(string: "https://example.com"), phone: "+44123456789", email: "venue@example.com", disabledDescription: "Fully accessible"))
    }
        
    @Test("FringePerformance")
    func testFringePerformance() throws {
        let testDate = Date(timeIntervalSince1970: 1691625600) // 2023-08-10 00:00:00 UTC
        try testEncodeDecodeEquates(value: FringePerformance(title: nil, type: .inPerson, isAtFixedTime: true, priceType: .paid, price: 12.50, concession: nil, priceString: "£12.50", start: testDate, end: testDate.addingTimeInterval(3600), durationMinutes: 60))
        try testEncodeDecodeEquates(value: FringePerformance(title: "Comedy Show", type: .onlineLive, isAtFixedTime: false, priceType: .payWhatYouCan, price: 5.00, concession: 3.50, priceString: "£5.00 (£3.50)", start: testDate, end: testDate.addingTimeInterval(7200), durationMinutes: 120))
    }

    @Test("FringeImage")
    func testFringeImage() throws {
        try testEncodeDecodeEquates(value: FringeImage.Orientation.landscape)
        try testEncodeDecodeEquates(value: FringeImage.ImageType.hero)
        try testEncodeDecodeEquates(value: FringeImage.Version(type: "original", width: 1920, height: 1080, mime: "image/jpeg", url: URL(string: "https://example.com/image.jpg")!))
        try testEncodeDecodeEquates(value: FringeImage(hash: "abc123", orientation: .landscape, type: .hero, versions: ["original": .init(type: "original", width: 1920, height: 1080, mime: "image/jpeg", url: URL(string: "https://example.com/image.jpg")!)]))
    }

    @Test("FringeEvent")
    func testFringeEvent() throws {
        let testDate = Date(timeIntervalSince1970: 1691625600) // 2023-08-10 00:00:00 UTC
        // Minimal event with required fields
        try testEncodeDecodeEquates(value: FringeEvent(title: "Test Show", artist: nil, country: nil, descriptionTeaser: nil, code: "TEST1", ageCategory: nil, description: "A test show", festival: "Edinburgh Festival Fringe", festivalId: "fringe", genre: "Comedy", genreTags: nil, performances: [], performanceSpace: FringePerformanceSpace(name: "Main Hall"), status: .active, url: URL(string: "https://tickets.edfringe.com/TEST1")!, venue: FringeVenue(code: "VENUE1", description: nil, name: "Test Venue", address: nil, position: .init(lat: 55.9533, lon: -3.1883), postCode: "EH1 1QS", webAddress: nil, phone: nil, email: nil, disabledDescription: nil), website: URL(string: "https://example.com")!, disabled: nil, images: [:], warnings: nil, updated: testDate, year: 2024))
        // Full event with all optional fields
        try testEncodeDecodeEquates(value: FringeEvent(title: "Comedy Spectacular", artist: "John Smith", country: "Scotland", descriptionTeaser: "A hilarious evening", code: "TEST2", ageCategory: "16+", description: "Full show description", festival: "Edinburgh Festival Fringe", festivalId: "fringe", genre: "Comedy", genreTags: "Stand-up, Improv", performances: [FringePerformance(title: "Evening Show", type: .inPerson, isAtFixedTime: true, priceType: .paid, price: 15.00, concession: 12.00, priceString: "£15.00 (£12.00)", start: testDate, end: testDate.addingTimeInterval(3600), durationMinutes: 60)], performanceSpace: FringePerformanceSpace(name: "Main Stage"), status: .active, url: URL(string: "https://tickets.edfringe.com/TEST2")!, venue: FringeVenue(code: "VENUE2", description: "A lovely venue", name: "Edinburgh Playhouse", address: "18-22 Greenside Place", position: .init(lat: 55.9571, lon: -3.1856), postCode: "EH1 3AA", webAddress: URL(string: "https://example.com"), phone: "+44123456789", email: "venue@example.com", disabledDescription: "Fully accessible"), website: URL(string: "https://comedyshow.com")!, disabled: FringeDisabled(otherServices: true, audio: true, captioningDates: ["2024-08-10"], signedDates: ["2024-08-11"]), images: ["main": FringeImage(hash: "abc123", orientation: .landscape, type: .hero, versions: ["original": .init(type: "original", width: 1920, height: 1080, mime: "image/jpeg", url: URL(string: "https://example.com/image.jpg")!)])], warnings: "Strong language", updated: testDate, year: 2024))
    }
}

// MARK: - Helpers

/// Encodes & decodes the value, then verifies the newly decoded value matches the original value
private func testEncodeDecodeEquates<T: Encodable & Decodable & Equatable>(
    value: T,
    sourceLocation: SourceLocation = #_sourceLocation
) throws {
    do {
        let encodedData = try JSONEncoder().encode(value)
        
        // Decoding for DB
        let decodedValueDB = try JSONDecoder().decode(T.self, from: encodedData)
        #expect(value == decodedValueDB, sourceLocation: sourceLocation)
        
        // Decoding for JSON
        let decodedValueJSON = try fringeJsonDecoder.decode(T.self, from: encodedData)
        #expect(value == decodedValueJSON, sourceLocation: sourceLocation)
    } catch {
        Issue.record(error, sourceLocation: sourceLocation)
    }
}
