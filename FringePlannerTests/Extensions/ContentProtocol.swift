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
        let generatedData = data()
        guard let value = generatedData as? Self else {
            Issue.record("""
                Type provided does not match
                Expected Type: 
                \(type(of: self))
                
                Found Type:
                \(type(of: generatedData))
                """, sourceLocation: sourceLocation)
            return
        }
        #warning("Without equatable support this will no longer work")
//        #expect(self == value, "Type matched but produced different values", sourceLocation: sourceLocation)
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
