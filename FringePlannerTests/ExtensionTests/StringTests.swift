//
//  StringTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 02/11/2024.
//

import Testing
@testable import FringePlanner

@Suite("String Extension Tests")
struct StringTests {
    
    @Test("`trimmed` correctly trims")
    func testTrimmed() {
        #expect("".trimmed == "")
        #expect("someValue    ".trimmed == "someValue")
        #expect("     someValue".trimmed == "someValue")
        #expect("someValue".trimmed == "someValue")
        #expect("\nsomeValue".trimmed == "someValue")
        #expect("\nsomeValue\n".trimmed == "someValue")
        #expect("\nsomeValue\nTest\n".trimmed == "someValue\nTest")
    }
    
    @Test("`nilOnEmpty` returns nil if empty")
    func testNilOnEmpty() {
        #expect("".nilOnEmpty == nil)
        #expect("    ".nilOnEmpty == "    ")
        #expect("test  ".nilOnEmpty == "test  ")
        #expect("  test  ".nilOnEmpty == "  test  ")
        #expect("  test".nilOnEmpty == "  test")
    }
}
