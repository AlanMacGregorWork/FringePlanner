//
//  EquatableCheckTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/03/2025.
//

import Foundation
import Testing
@testable import FringePlanner

@Suite("EquatableCheck Tests")
struct EquatableCheckTests {
    
    @Test("Basic initializer with custom equality function")
    func testBasicInitializer() {
        let check = EquatableCheck<Int, Int>(lhsName: "left", rhsName: "right", isEqual: { $0 == $1 })
        
        #expect(check.isEqual(lhs: 5, rhs: 5))
        #expect(!check.isEqual(lhs: 5, rhs: 6))
    }
    
    @Test("KeyPath initializer for non-optional values")
    func testKeyPathInitializer() {
        let check = EquatableCheck(lhsName: "left", rhsName: "right", lhsKeyPath: \TestStruct.value, rhsKeyPath: \TestStruct.value)
        
        #expect(check.isEqual(lhs: TestStruct(value: 5), rhs: TestStruct(value: 5)))
        #expect(!check.isEqual(lhs: TestStruct(value: 5), rhs: TestStruct(value: 6)))
    }
    
    @Test("KeyPath initializer for optional LHS")
    func testOptionalLHSInitializer() {
        let check = EquatableCheck(lhsName: "left", rhsName: "right", lhsKeyPath: \TestStruct.value, rhsKeyPath: \TestStruct.value)
        
        #expect(check.isEqual(lhs: TestStruct(value: 5), rhs: TestStruct(value: 5)))
        #expect(!check.isEqual(lhs: TestStruct(value: 5), rhs: TestStruct(value: 6)))
        #expect(check.isEqual(lhs: TestStruct(value: nil), rhs: TestStruct(value: nil)))
        #expect(!check.isEqual(lhs: TestStruct(value: nil), rhs: TestStruct(value: 5)))
    }
    
    @Test("KeyPath initializer for optional RHS")
    func testOptionalRHSInitializer() {
        let check = EquatableCheck(lhsName: "left", rhsName: "right", lhsKeyPath: \TestStruct.value, rhsKeyPath: \TestStruct.value)
        
        #expect(check.isEqual(lhs: TestStruct(value: 5), rhs: TestStruct(value: 5)))
        #expect(!check.isEqual(lhs: TestStruct(value: 5), rhs: TestStruct(value: 6)))
        #expect(check.isEqual(lhs: TestStruct(value: nil), rhs: TestStruct(value: nil)))
        #expect(!check.isEqual(lhs: TestStruct(value: 5), rhs: TestStruct(value: nil)))
    }

    // MARK: - Helper Structs

    struct TestStruct {
        let value: Int?
    }        
}
