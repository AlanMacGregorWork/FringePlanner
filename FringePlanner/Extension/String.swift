//
//  String.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 02/11/2024.
//

extension String {
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
        let pattern = "<[a-zA-Z][^>]*>"
        return self.range(of: pattern, options: .regularExpression) != nil
    }
}
