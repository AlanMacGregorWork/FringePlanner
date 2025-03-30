//
//  EquatableCheck.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 07/01/2025.
//

/// A struct to check if two values are equal
struct EquatableCheck<LHSType, RHSType> {
    let lhsName: String
    let rhsName: String
    let isEqual: (LHSType, RHSType) -> Bool

    func isEqual(lhs: LHSType, rhs: RHSType) -> Bool {
        isEqual(lhs, rhs)
    }
}

// MARK: Helper Init

extension EquatableCheck {
    /// Initialise an EquatableCheck using a keyPath
    init<T: Equatable>(lhsName: String, rhsName: String, lhsKeyPath: KeyPath<LHSType, T>, rhsKeyPath: KeyPath<RHSType, T>) {
        self.lhsName = lhsName
        self.rhsName = rhsName
        self.isEqual = { lhs, rhs in
            lhs[keyPath: lhsKeyPath] == rhs[keyPath: rhsKeyPath]
        }
    }

    /// Initialise an EquatableCheck using an optional-sided keyPath
    init<T: Equatable>(lhsName: String, rhsName: String, lhsKeyPath: KeyPath<LHSType, T?>, rhsKeyPath: KeyPath<RHSType, T>) {
        self.lhsName = lhsName
        self.rhsName = rhsName
        self.isEqual = { lhs, rhs in
            lhs[keyPath: lhsKeyPath] == rhs[keyPath: rhsKeyPath]
        }
    }

    /// Initialise an EquatableCheck using an optional-sided keyPath
    init<T: Equatable>(lhsName: String, rhsName: String, lhsKeyPath: KeyPath<LHSType, T>, rhsKeyPath: KeyPath<RHSType, T?>) {
        self.lhsName = lhsName
        self.rhsName = rhsName
        self.isEqual = { lhs, rhs in
            lhs[keyPath: lhsKeyPath] == rhs[keyPath: rhsKeyPath]
        }
    }
}
