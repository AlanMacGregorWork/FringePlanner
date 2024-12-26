//
//  ContentProtocol.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 27/10/2024.
//

import Testing
@testable import FringePlanner

extension ViewDataProtocol {
    /// Triggers an `expect` test specifically for fringe data
    func expect<T: ViewDataProtocol>(
        @FringeDataResultBuilder _ data: () -> (T),
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        guard let value = data() as? Self else {
            Issue.record("Type provided does not match\n\(self)", sourceLocation: sourceLocation)
            return
        }
        #expect(self == value, "Type matched but produced different values", sourceLocation: sourceLocation)
    }
}

extension ContentProtocol {
    /// Triggers an `expect` test specifically for fringe data
    @MainActor
    func expect<T: ViewDataProtocol>(
        @FringeDataResultBuilder _ data: () -> (T),
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        Self.Structure(input: self).expect(data, sourceLocation: sourceLocation)
    }
}

extension BaseStructureProtocol {
    /// Triggers an `expect` test specifically for fringe data
    @MainActor
    func expect<T: ViewDataProtocol>(
        @FringeDataResultBuilder _ data: () -> (T),
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        self.structure.expect(data, sourceLocation: sourceLocation)
    }
}

// MARK: - Helpers

/// Provides a basic `==` for two parameter packs
/// - Note: Does not make the parameter packs conform to `Equatable`
private func == <each Element: Equatable>(lhs: (repeat each Element), rhs: (repeat each Element)) -> Bool {
    for (left, right) in repeat (each lhs, each rhs) {
        guard left == right else { return false }
    }
    return true
}
