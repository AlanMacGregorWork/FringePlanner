//
//  PseudoRandomNumberGeneratorTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/02/2025.
//

import Testing
@testable import FringePlanner

@Suite("PseudoRandomNumberGenerator Tests")
struct PseudoRandomNumberGeneratorTests {
    @Test("Returns repeatable values")
    func testReturnsRepeatableValues() {
        let generator1 = PseudoRandomIntGenerator(seed: 123)
        #expect(generator1.get() == 937328)
        #expect(generator1.get() == 714643)
        #expect(generator1.get() == 497757)

        // A generator with the same seed should return the same values
        let generator2 = PseudoRandomIntGenerator(seed: 123)
        #expect(generator2.get() == 937328)
        #expect(generator2.get() == 714643)
        #expect(generator2.get() == 497757)
    }

    @Test("Returns different values for different seeds")
    func testReturnsDifferentValuesForDifferentSeeds() {
        let generator1 = PseudoRandomIntGenerator(seed: 343)
        #expect(generator1.get() == 556937)
        #expect(generator1.get() == 879044)
        #expect(generator1.get() == 290492)
        
        let generator2 = PseudoRandomIntGenerator(seed: 124)
        #expect(generator2.get() == 985599)
        #expect(generator2.get() == 801754)
        #expect(generator2.get() == 428633)
    }

    @Test("Returns values within the bounds of the maxNumber")
    func testReturnsValuesWithinTheBoundsOfTheMaxNumber() {
        let generator = PseudoRandomIntGenerator(seed: 123)
        let maxNumber = 10
        var zeroEncountered = false
        var maxNumberEncountered = false
        
        // Enumerate a large number of values to ensure that the bounds are not exceeded
        for _ in 0..<100 {
            let randomNumber = generator.get(maxNumber: maxNumber)
            #expect(randomNumber >= 0, "Number should no be negative")
            #expect(randomNumber <= maxNumber, "Number should be less or equal to maxNumber")
            zeroEncountered = zeroEncountered || randomNumber == 0
            maxNumberEncountered = maxNumberEncountered || randomNumber == maxNumber
        }
        
        // Ensure that the bounds of the min and max number were reached
        #expect(zeroEncountered, "0 should have been encountered")
        #expect(maxNumberEncountered, "maxNumber should have been encountered")
    }
}
