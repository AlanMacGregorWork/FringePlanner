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
}
