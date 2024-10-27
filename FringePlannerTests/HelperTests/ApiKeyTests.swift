//
//  ApiKeyTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 27/10/2024.
//

import Testing
@testable import FringePlanner

@Suite("ApiKey Tests")
struct ApiKeyTests {
    @Test("All keys contain data", arguments: ApiKey.allCases)
    func testAllKeysContainData(_ key: ApiKey) {
        #expect(!key.value.isEmpty, "Key must contain data")
        #expect(!(key.value.hasPrefix("$(") && key.value.hasSuffix(")")), "Key must have been correctly pulled from configuration")
    }
}
