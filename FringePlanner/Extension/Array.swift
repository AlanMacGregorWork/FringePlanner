//
//  Array.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/02/2025.
//

import Foundation

extension Array where Element: Hashable {
    /// Checks if two arrays contain the same elements, regardless of order
    /// - Returns: `true` if the arrays contain the same elements, `false` otherwise
    func unorderedElementsEqual(_ other: Self) -> Bool {
        NSCountedSet(array: self) == NSCountedSet(array: other)
    }
}
