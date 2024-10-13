//
//  EdgeInsetsTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 17/09/2024.
//

import Testing
import SwiftUI
@testable import FringePlanner

struct EdgeInsetsTests {
    
    @Test("`zero` property has all its values set to zero")
    func zeroPropertyHasValuesSetToZero() async throws {
        #expect(EdgeInsets.zero == .init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}
