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
}
