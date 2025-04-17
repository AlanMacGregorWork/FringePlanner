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
    
    @Test("`withoutHTMLTags` correctly removes HTML tags")
    func testWithoutHTMLTags() {
        // Empty string
        #expect("".withoutHTMLTags == "")
        
        // Plain text (no change expected)
        #expect("Plain text content".withoutHTMLTags == "Plain text content")
        #expect("Text with brackets like 2 < 3 and 5 > 4".withoutHTMLTags == "Text with brackets like 2 < 3 and 5 > 4")
        
        // Basic HTML tags
        #expect("<p>Simple paragraph</p>".withoutHTMLTags == "Simple paragraph")
        #expect("<br/>".withoutHTMLTags == "")
        #expect("<div>Content</div>".withoutHTMLTags == "Content")
        
        // HTML with attributes
        #expect("<div class=\"test\">With attributes</div>".withoutHTMLTags == "With attributes")
        #expect("<img src=\"image.jpg\" alt=\"Image\">".withoutHTMLTags == "")
        
        // Nested tags
        #expect("<div><p>Nested content</p></div>".withoutHTMLTags == "Nested content")
        #expect("<ul><li>Item 1</li><li>Item 2</li></ul>".withoutHTMLTags == "Item 1Item 2")
        
        // Mixed content
        #expect("Text before <span>and tag</span> after".withoutHTMLTags == "Text before and tag after")
        #expect("Line 1<br>Line 2".withoutHTMLTags == "Line 1Line 2")
        
        // Complex HTML
        let complexHTML = """
        <div class="container">
          <h1>Title</h1>
          <p>This is a <b>paragraph</b> with <i>formatted</i> text.</p>
        </div>
        """
        #expect(complexHTML.withoutHTMLTags == "\n  Title\n  This is a paragraph with formatted text.\n")
    }
}
