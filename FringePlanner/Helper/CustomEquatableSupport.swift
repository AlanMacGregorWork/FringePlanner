//
//  CustomEquatableSupport.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 18/01/2025.
//

/// Simplifies the construction of equate functions between two different types
protocol CustomEquatableSupport {
    /// The type that will  be used to equate with this object
    associatedtype OtherEquatableType
    /// To perform an equatable on two different types a single equal check is required
    static func == (lhs: Self, rhs: OtherEquatableType) -> Bool
}

extension CustomEquatableSupport {
    // Both non-optional values should not match
    static func != (lhs: Self, rhs: OtherEquatableType) -> Bool {
        // Returns the negative result of` ==`
        !(lhs == rhs)
    }
}

extension Optional where Wrapped: CustomEquatableSupport {
    // Both optional values should match
    static func == (lhs: Self, rhs: Wrapped.OtherEquatableType?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            // Both are nil so they must equate
            return true
        case (.some(_), .none), (.none, .some(_)):
            // Only one is nil so it can't equate
            return false
        case (let lhs?, let rhs?):
            // Both values exist so the equatable check can occur
            return lhs == rhs
        }
    }
    
    // Only one value exists and should match
    static func == (lhs: Self, rhs: Wrapped.OtherEquatableType) -> Bool {
        return lhs == (rhs as Wrapped.OtherEquatableType?)
    }
    
    // Only one value exists and should not match
    static func != (lhs: Wrapped.OtherEquatableType?, rhs: Self) -> Bool {
        !(rhs == lhs)
    }
}
