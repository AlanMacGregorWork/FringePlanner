//
//  Dictionary.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 30/11/2024.
//

extension Dictionary {
    /// Returns the keys of the dictionary without any associated values
    var cleanKeys: [Key] {
        self.map(\.key)
    }
}
