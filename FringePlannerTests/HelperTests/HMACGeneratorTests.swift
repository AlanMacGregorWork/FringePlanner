//
//  HMACGeneratorTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/10/2024.
//

import Testing
@testable import FringePlanner

@Suite("HMACGenerator Tests")
struct HMACGeneratorTests {
    @Test("Creates string from valid data")
    func hmacCreatesString() throws {
        #expect(try HMACGenerator.createHash(for: "someNewCode", key: "hhrg8agawr-wngrejnjfwei298869fhHr") == "540fd2b2b2eb8f7a550a2c5ecd99b7fb4cb8d2f5")
        #expect(try HMACGenerator.createHash(for: "someNewCode", key: "jeibviubeibvvb78ef4-rgergerg7f8hv") == "f6f482dfba4e873d2180662e83897211225cefc6")
        #expect(try HMACGenerator.createHash(for: "someDifferentCode", key: "jeibviubeibvvb78ef4-rgergerg7f8hv") == "fd66c6208e07be15803fc1c0b6f2ff550ec03743")
    }
    
    @Test("Throws from missing data")
    func hmacThrowsFromMissingData() throws {
        #expect(throws: HMACGenerator.GeneratorError.keyIsEmpty, performing: { try HMACGenerator.createHash(for: "someNewCode", key: "") })
        #expect(throws: HMACGenerator.GeneratorError.keyIsEmpty, performing: { try HMACGenerator.createHash(for: "", key: "") })
        #expect(throws: HMACGenerator.GeneratorError.inputIsEmpty, performing: { try HMACGenerator.createHash(for: "", key: "someKey") })
    }
}
