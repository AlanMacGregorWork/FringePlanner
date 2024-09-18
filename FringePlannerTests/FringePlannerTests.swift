//
//  FringePlannerTests.swift
//  FringePlannerTests
//
//  Created by Alan MacGregor on 16/09/2024.
//

import Foundation
import Testing
@testable import FringePlanner

struct FringePlannerTests {

    @Test func testExample() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func doAnotherTest() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    
    @Test func failureTest() throws {
        try #require(Date.now == Date.now.addingTimeInterval(34))
    }

}


import XCTest

final class DeepLinkHandlerTests: XCTestCase {
    
    func testValidateURLShouldContinueInApp() {
        
    }
    
    func testOther() {
        XCTFail("Failure message here this test")
    }
}
