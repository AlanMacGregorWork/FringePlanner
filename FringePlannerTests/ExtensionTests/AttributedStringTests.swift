//
//  AttributedStringTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 27/12/2024.
//

import Testing
import SwiftUI
@testable import FringePlanner

@Suite("AttributedString Tests")
struct AttributedStringTests {
    
    @Suite("Sanity Checks")
    struct SanityChecks {
        @Test("Attributes should equate if they are built the same way")
        func verifyFormatEquates() {
            let html = "<b>Text</b>"
            let withHTMLFormatting1 = AttributedString(fromHTML: html)
            let withHTMLFormatting2 = AttributedString(fromHTML: html)
            let withoutHTMLFormatting1 = AttributedString(html)
            let withoutHTMLFormatting2 = AttributedString(html)
            
            // Attributes built the same way are equatable
            #expect(withHTMLFormatting1 == withHTMLFormatting2)
            #expect(withoutHTMLFormatting1 == withoutHTMLFormatting2)
            
            // Attributes not built the same way are not equatable
            #expect(withHTMLFormatting1 != withoutHTMLFormatting1)
            #expect(withHTMLFormatting2 != withoutHTMLFormatting2)
        }
    }
    
    @Suite("hasTrimmedPrefix")
    struct HasTrimmedPrefixTests {
        let testString = AttributedString("Some Value")
        
        @Test("Returns true on matching prefix")
        func testExactPrefixMatch() {
            #expect(AttributedString("Some Value In Here").hasTrimmedPrefix(AttributedString("Some Value")))
            #expect(AttributedString("Alternative Text").hasTrimmedPrefix(AttributedString("Alt")))
            #expect(AttributedString("Example Text").hasTrimmedPrefix(AttributedString("Example Text")), "As long as the prefix is still at the start of the String, having it use the ensite string is valid")
        }
        
        @Test("Returns true on matching prefix (with trimming)")
        func testPrefixMatchWithTrimming() {
            #expect(AttributedString("  Some Value In Here    ").hasTrimmedPrefix(AttributedString("   Some Value ")))
            #expect(AttributedString(" Alternative Text  ").hasTrimmedPrefix(AttributedString("       Alt       ")))
        }
        
        @Test("Returns false on nil prefix")
        func testNilPrefix() {
            #expect(!AttributedString("General String").hasTrimmedPrefix(nil))
            #expect(!AttributedString("").hasTrimmedPrefix(nil), "Even an empty string will require a non nil prefix")
        }
        
        @Test("Returns false on non-matching prefix")
        func testNonMatchingPrefix() {
            #expect(!AttributedString("Some Text").hasTrimmedPrefix("Other Text"))
            #expect(!AttributedString("123 Some Text").hasTrimmedPrefix("123 Other Text"))
        }
    }
}
