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
    
    @Test("`mayContainHTML` correctly identifies HTML content")
    func testMayContainHTML() {
        // Possibly no HTML
        #expect("".mayContainHTML == false)
        #expect("Plain text content".mayContainHTML == false)
        #expect("Text with brackets but not tags: 2 < 3 and 5 > 4".mayContainHTML == false)
        // May include HTML
        #expect("<p>Simple paragraph</p>".mayContainHTML == true)
        #expect("<div class=\"test\">With attributes</div>".mayContainHTML == true)
        #expect("<br/>".mayContainHTML == true)
        #expect("<img src=\"image.jpg\" alt=\"Image\">".mayContainHTML == true)
        #expect("Text before <span>and tag</span> after".mayContainHTML == true)
    }
}
