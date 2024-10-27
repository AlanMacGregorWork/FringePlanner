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
    func expect(@FringeDataResultBuilder _ data: () -> ContentType) {
        #expect(self.generateStructure() == data())
    }
}
