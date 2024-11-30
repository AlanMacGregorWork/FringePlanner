//
//  ContentProtocol.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 27/10/2024.
//

import Testing
@testable import FringePlanner

extension ContentProtocol {
    /// Triggers an `expect` test specifically for fringe data
    @MainActor
    func expect<T: ViewDataProtocol>(@FringeDataResultBuilder _ data: () -> (T)) {
        if let value = data() as? Self.Structure.StructureType {
            #expect(Self.Structure(input: self).structure == value)
        } else {
            Issue.record("Structure provided does not match")
        }
    }
}

/// Provides a basic `==` for two parameter packs
/// - Note: Does not make the parameter packs conform to `Equatable`
private func == <each Element: Equatable>(lhs: (repeat each Element), rhs: (repeat each Element)) -> Bool {
    for (left, right) in repeat (each lhs, each rhs) {
        guard left == right else { return false }
    }
    return true
}
