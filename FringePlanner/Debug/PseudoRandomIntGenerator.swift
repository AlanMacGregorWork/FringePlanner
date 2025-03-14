//
//  PseudoRandomIntGenerator.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/02/2025.
//

#if DEBUG

/// Pseudo-random number generator to allow for repeatable random values
class PseudoRandomIntGenerator {
    private var internalGenerator: Generator

    init(seed: Int) {
        self.internalGenerator = Generator(seed: UInt64(seed))
    }
    
    /// Returns a pseudo-random integer between 0 and `maxNumber`
    func get(maxNumber: Int = 1000000) -> Int {
        // Uses modulo to ensure the result is within the bounds of the maxNumber
        // Adding 1 to the maxNumber to include the maxNumber in the range
        Int(internalGenerator.next() % UInt64(maxNumber + 1))
    }
    
    /// Note: Generator contained here to block outside access to `next()`
    private struct Generator: RandomNumberGenerator {
        var seed: UInt64
        
        mutating func next() -> UInt64 {
            // Multiply the seed with a prime number & allow overflow
            seed = seed &* 48271
            return seed
        }
    }
}

#endif
