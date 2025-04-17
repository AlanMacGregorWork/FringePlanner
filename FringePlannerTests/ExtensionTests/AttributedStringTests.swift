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
        @MainActor
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
    
    @Suite("init(from:<html>)")
    struct InitFromHtmlTests {
        @MainActor
        @Test("Converts HTML into a rendered format")
        func testConvertsHTML() throws {
            let html = "<b>Some</b>Other<br>Text Here<br>"
            let attributedString = try #require(AttributedString(fromHTML: html), "Attributed string should be generated from HTML")
            #expect(NSAttributedString(attributedString).string ==
            """
            SomeOther
            Text Here
            
            """)
        }
    }

    @Suite("StringProvider")
    struct StringProviderTests {
        @Suite("init(_ string: String)")
        struct InitWithStringTests {
            @Test("init correctly identifies HTML content")
            func testInitWithHTMLContent() throws {
                let htmlString = "<p>This is <b>HTML</b> content</p>"
                try #require(htmlString.mayContainHTML, "Sanity Check: HTML string should be detected as containing HTML")
                #expect(AttributedString.StringProvider(htmlString) == .htmlString(htmlString))
            }
            
            @Test("init correctly handles plain text")
            func testInitWithPlainText() throws {
                let plainString = "This is plain text content"
                try #require(!plainString.mayContainHTML, "Sanity Check: Plain text should not be detected as containing HTML")
                #expect(AttributedString.StringProvider(plainString) == .attributedString(AttributedString(plainString)))
            }
        }
        
        @Suite("hasTrimmedPrefix")
        struct HasTrimmedPrefixTests {
            @Test("hasTrimmedPrefix correctly identifies prefixes between StringProviders")
            func testHasTrimmedPrefix() {
                // Valid comparisons
                #expect(AttributedString.StringProvider.htmlString("Some Value In Here").hasTrimmedPrefix(AttributedString.StringProvider.htmlString("Some Value")))
                #expect(AttributedString.StringProvider.attributedString(AttributedString("Some Value In Here")).hasTrimmedPrefix(AttributedString.StringProvider.attributedString(AttributedString("Some Value"))))
                #expect(AttributedString.StringProvider.attributedString(AttributedString("Some Value In Here")).hasTrimmedPrefix(AttributedString.StringProvider.htmlString("Some Value")))
                #expect(AttributedString.StringProvider.htmlString("Some Value In Here").hasTrimmedPrefix(AttributedString.StringProvider.attributedString("Some Value")))
                
                // Invalid comparisons
                #expect(!AttributedString.StringProvider.htmlString("Some Value In Here").hasTrimmedPrefix(AttributedString.StringProvider.htmlString("Some Other Value")))
                #expect(!AttributedString.StringProvider.attributedString(AttributedString("Some Value In Here")).hasTrimmedPrefix(AttributedString.StringProvider.attributedString(AttributedString("Some Other Value"))))
                #expect(!AttributedString.StringProvider.htmlString("Some Value In Here").hasTrimmedPrefix(AttributedString.StringProvider.attributedString("Some Other Value")))
                
                // Empty string comparisons
                #expect(!AttributedString.StringProvider.htmlString("").hasTrimmedPrefix(AttributedString.StringProvider.htmlString("Some Value")))
                #expect(!AttributedString.StringProvider.attributedString(AttributedString("")).hasTrimmedPrefix(AttributedString.StringProvider.attributedString(AttributedString("Some Value"))))
                #expect(!AttributedString.StringProvider.htmlString("").hasTrimmedPrefix(AttributedString.StringProvider.attributedString("Some Value")))
                #expect(AttributedString.StringProvider.htmlString("").hasTrimmedPrefix(AttributedString.StringProvider.htmlString("")))
                #expect(AttributedString.StringProvider.attributedString(AttributedString("")).hasTrimmedPrefix(AttributedString.StringProvider.attributedString(AttributedString(""))))
                #expect(AttributedString.StringProvider.attributedString(AttributedString("")).hasTrimmedPrefix(AttributedString.StringProvider.htmlString("")))
            
                // HTML to HTML comparison
                #expect(AttributedString.StringProvider.htmlString("Some Value In Here").hasTrimmedPrefix(AttributedString.StringProvider.htmlString("<p>Some Value In Here</p>")))
                #expect(AttributedString.StringProvider.htmlString("<p>Some Value In Here</p>").hasTrimmedPrefix(AttributedString.StringProvider.htmlString("<p>Some Value In Here</p>")))
                
                // Typographically enhanced comparison for right double quotes
                let curlyQuotes = "\u{201C}Quote test\u{201D}"
                let straightQuotes = "\"Quote test\""
                #expect(AttributedString.StringProvider.htmlString(curlyQuotes.typographicallyEnhanced).hasTrimmedPrefix(AttributedString.StringProvider.htmlString(straightQuotes)))
                #expect(AttributedString.StringProvider.attributedString(AttributedString(curlyQuotes.typographicallyEnhanced)).hasTrimmedPrefix(AttributedString.StringProvider.attributedString(AttributedString(straightQuotes))))
            }
        }
    }
}
