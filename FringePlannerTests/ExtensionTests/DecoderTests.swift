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
    func testCanValidateMissingKeys() throws {
        let decoder = fringeJsonDecoder
        #expect(try decoderIncludesValidateMissingValuesKey(decoder))
    }

    @Test("`canValidateMissingKeys` returns false on non-Fringe decoders")
    func testCanValidateMissingKeysOnNonFringeDecoder() throws {
        let decoder = JSONDecoder()
        #expect(try !decoderIncludesValidateMissingValuesKey(decoder))
    }

    private func decoderIncludesValidateMissingValuesKey(_ decoder: JSONDecoder) throws -> Bool {
        class Container {
            var canValidateMissingKeys = true
        }
        struct TestStruct: Codable {
            let value: Bool
            nonisolated(unsafe) static var decoderHasKey: Bool = false
            
            init(from decoder: Decoder) throws {
                let testKey = try #require(CodingUserInfoKey(rawValue: "test-key"))
                let container = try #require(decoder.userInfo[testKey] as? Container)
                container.canValidateMissingKeys = decoder.canValidateMissingKeys
                self.value = true
            }
        }
        
        // Add the container to the userInfo
        let testKey = try #require(CodingUserInfoKey(rawValue: "test-key"))
        try #require(!decoder.userInfo.contains(where: { $0.key == testKey}), "Sanity Check: Test Key should not exist")
        decoder.userInfo[testKey] = Container()
        
        // Decode the struct
        _ = try? decoder.decode(TestStruct.self, from: Data("{}".utf8))
        
        // Access the `canValidateMissingKeys` value
        let container = try #require(decoder.userInfo[testKey] as? Container)
        return container.canValidateMissingKeys
    }
}
