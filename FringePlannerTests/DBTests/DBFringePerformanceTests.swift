//
//  DBFringePerformanceTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/12/2024.
//

import Foundation
import Testing
@testable import FringePlanner

@Suite("DBFringePerformance Tests")
class DBFringePerformanceTests: DBFringeModelTestProtocol {
    typealias DBModelType = DBFringePerformance
    
    init() throws {
        try validateContent()
    }
    
    @Test("Database model is correctly updated from API model")
    func testUpdateCopiesAllFields() throws {
        try autoTestUpdateCopiesAllFields()
    }
}
