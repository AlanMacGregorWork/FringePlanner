//
//  FBPerformanceSpace.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

/// Defines a general location for the performance
struct FBPerformanceSpace: Equatable, Hashable {
    let name: String
}

extension FBPerformanceSpace: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        self.name = try container.decode(String.self, forKey: "name").trimmed

        container.validateAssumedNil(keys: ["ageLimit", "ageLimited", "capacity", "wheelchairAccess"])
    }
}
