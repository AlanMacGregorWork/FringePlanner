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
