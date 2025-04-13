//
//  DecoderTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 07/04/2025.
//

import Testing
import Foundation
@testable import FringePlanner

@Suite("Decoder Extension Tests")
struct DecoderTests {
    
    @Test("`canValidateMissingKeys` returns true on Fringe decoder")
    func testCanValidateMissingKeys() {
        let decoder = fringeJsonDecoder
        #expect(Self.decoderIncludesValidateMissingValuesKey(decoder))
    }

    @Test("`canValidateMissingKeys` returns false on non-Fringe decoders")
    func testCanValidateMissingKeysOnNonFringeDecoder() {
        let decoder = JSONDecoder()
        #expect(!Self.decoderIncludesValidateMissingValuesKey(decoder))
    }

    private static func decoderIncludesValidateMissingValuesKey(_ decoder: JSONDecoder) -> Bool {
        struct TestStruct: Codable {
            let value: Bool
            nonisolated(unsafe) static var decoderHasKey: Bool = false
            
            init(from decoder: Decoder) throws {
                TestStruct.decoderHasKey = decoder.canValidateMissingKeys
                self.value = true
            }
        }
        
        _ = try? decoder.decode(TestStruct.self, from: Data("{}".utf8))
        return TestStruct.decoderHasKey
    }
}
