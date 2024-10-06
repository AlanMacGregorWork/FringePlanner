//
//  MakeEquatable.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/10/2024.
//

/// Makes a type conform `Equatable` by always being valid & `Hashable` by not including itself in the hash.
/// - Note: Variable will not be mutable
@propertyWrapper class MakeEquatableReadOnly<T>: Equatable, Hashable {
    fileprivate(set) var wrappedValue: T
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    // If the type already conforms to Equatable, then there is no need to use this property as the type
    // will have a more accurate calculation
    @available(*, deprecated, message: "Value is Equatable so should not require this property wrapper")
    init(wrappedValue: T) where T: Equatable {
        self.wrappedValue = wrappedValue
    }
    
    static func == (lhs: MakeEquatableReadOnly, rhs: MakeEquatableReadOnly) -> Bool {
        // Override Equatable to always be true
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        // No hashing needed
    }
}

/// Makes a type conform `Equatable` by always being valid & `Hashable` by not including itself in the hash.
/// - Note: Variable will be mutable
@propertyWrapper class MakeEquatableWriteable<T>: MakeEquatableReadOnly<T> {
    override var wrappedValue: T {
        get { super.wrappedValue }
        set { super.wrappedValue = newValue }
    }
}
