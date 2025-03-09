//
//  ArrayTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/02/2025.
//

import Testing
@testable import FringePlanner

@Suite("Array Tests")
struct ArrayTests {
    @Suite("`unorderedElementsEqual(_:)`")
    struct UnorderedElementsEqualTests {
        @Test("Array contain all elements")
        func testArrayContainAllElements() {
            // Ordered arrays
            #expect([1, 2, 3].unorderedElementsEqual([1, 2, 3]))
            #expect(["A", "B", "C"].unorderedElementsEqual(["A", "B", "C"]))

            // Unordered arrays
            #expect([1, 2, 3].unorderedElementsEqual([3, 2, 1]))
            #expect(["A", "B", "C"].unorderedElementsEqual(["C", "B", "A"]))
        }
        
        @Test("Array does not contain all elements")
        func testArrayDoesNotContainAllElements() {
            // With same size
            #expect(![1, 2, 3].unorderedElementsEqual([3, 2, 4]))
            #expect(!["A", "B", "C"].unorderedElementsEqual(["C", "B", "D"]))
            
            // With different sizes (input array is longer, even though all elements are present in the other array)
            #expect(![1, 2, 3].unorderedElementsEqual([3, 2, 4, 1]))
            #expect(!["A", "B", "C"].unorderedElementsEqual(["C", "B", "D", "A"]))
            
            // With different sizes (input array is shorter, even though all elements are present in the other array)
            #expect(![3, 2, 4, 1].unorderedElementsEqual([1, 2, 3]))
            #expect(!["C", "B", "D", "A"].unorderedElementsEqual(["A", "B", "C"]))
        }
    }
}
