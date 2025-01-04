//
//  DBFringeVenueTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 28/12/2024.
//

import Foundation
import Testing
@testable import FringePlanner

@Suite("DBFringeVenue Tests")
struct DBFringeVenueTests: DBFringeModelTestProtocol {
    typealias DBModelType = DBFringeVenue
    
    init() throws {
        try validateContent()
    }
    
    @Test("Database model is correctly updated from API model")
    func testUpdateCopiesAllFields() throws {
        try autoTestUpdateCopiesAllFields()
    }
}
