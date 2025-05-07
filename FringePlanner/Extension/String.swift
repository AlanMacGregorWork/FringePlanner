//
//  String.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 02/11/2024.
//

extension String {
    /// Pattern to match HTML tags
    private static let htmlTagPattern = "</?[a-zA-Z][^>]*>"

    /// Returns a string without the new lines
    var trimmed: Self {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns a string with proper typographic characters and normalized quotes
    var typographicallyEnhanced: Self {
        var result = self
        
        // Convert any curly quotes to standard straight quotes
        result = result.replacingOccurrences(of: "\u{201C}", with: "\"") // Left double quote to straight quote
        result = result.replacingOccurrences(of: "\u{201D}", with: "\"") // Right double quote to straight quote
        result = result.replacingOccurrences(of: "\u{2018}", with: "'") // Left single quote to straight quote
        result = result.replacingOccurrences(of: "\u{2019}", with: "'") // Right single quote to straight quote
        
        // Replace three dots with ellipsis
        result = result.replacingOccurrences(of: "...", with: "\u{2026}")
        
        // Replace common symbol representations
        result = result.replacingOccurrences(of: "(c)", with: "\u{00A9}") // Copyright
        result = result.replacingOccurrences(of: "(r)", with: "\u{00AE}") // Registered trademark
        result = result.replacingOccurrences(of: "(tm)", with: "\u{2122}") // Trademark
        
        // Replace double hyphen with em dash
        result = result.replacingOccurrences(of: "--", with: "\u{2014}")
        
        return result
    }
    
    /// Will return nil if the string is empty
    var nilOnEmpty: Self? {
        return !self.isEmpty ? self : nil
    }
    
    /// Performs a basic check to determine if the string might contain HTML
    /// by looking for patterns like "<tag>"
    var mayContainHTML: Bool {
        // Look for a pattern that starts with < followed by a letter (tag name)
        // This helps distinguish HTML tags from mathematical expressions
        return self.range(of: Self.htmlTagPattern, options: .regularExpression) != nil
    }
    
    /// Returns the string with all HTML tags removed
    /// Preserves the text content between tags
    var withoutHTMLTags: Self {
        // Match HTML tags that start with < followed by a letter or / (for closing tags)
        // This avoids matching mathematical expressions like "2 < 3"
        return self.replacingOccurrences(of: Self.htmlTagPattern, with: "", options: .regularExpression)
    }
    
    /// Returns the string with all new lines removed
    var withoutNewLines: Self {
        self.components(separatedBy: .newlines).joined()
    }
}
