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
