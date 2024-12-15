//
//  AnyCodingKey.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

/// Allows generating keys from JSON decoding when the keys are unknown
struct AnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
    
    init(key: String) {
        self.stringValue = key
        self.intValue = nil
    }
}

// MARK: Helper

extension KeyedDecodingContainer where K == AnyCodingKey {
    /// Allows decoding by just using a String value
    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        try self.decodeIfPresent(type, forKey: .init(key: key))
    }
    
    /// Allows decoding by just using a String value
    func decode<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T {
        try self.decode(type, forKey: .init(key: key))
    }
    
    /// Note: Some keys were not found to contain values during development, and may not contain data using
    /// a real-world source. To ensure that we're still tracking the data, the following will assert if useful
    /// data is returned and requires updating the model
    func validateAssumedNil(keys: [String]) {
        for key in keys {
            self.verifyExistsAndNil(key)
        }
    }
    
    private func verifyExistsAndNil(_ key: String) {
        // Validate key exists
        if !contains(.init(key: key)) {
            return fringeAssertFailure("`\(key)` no longer exists")
        }
        
        // Validate key is nil
        do {
            if try decodeNil(forKey: .init(key: key)) {
                // Value is nil, so fine
                return
            }
        } catch {
            return fringeAssertFailure("`\(key) decodeNil failed: \(error)")
        }
        
        // If the value isn't nil, check if it's an empty `String` which may erroneously be included
        // rather than showing `nil`
        if let string = try? decode(String.self, forKey: key), string.isEmpty {
            // Value is empty, so fine
            return
        } else if let array = try? decode([String].self, forKey: key), array.isEmpty {
            // Value is empty, so fine
            return
        }
        
        // Value must have some form of data
        return fringeAssertFailure("`\(key)` incorrectly contains data")
    }
}
