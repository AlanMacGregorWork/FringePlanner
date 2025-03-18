//
//  FringePerformanceSpace.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

/// Defines a general location for the performance
struct FringePerformanceSpace: Equatable, Hashable {
    let name: String?
    let ageLimited: Bool?
}

// MARK: Codable

extension FringePerformanceSpace: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        self.name = try container.decodeIfPresent(String.self, forKey: "name")?.trimmed
        self.ageLimited = try container.decodeIfPresent(Bool.self, forKey: "ageLimited")

        container.validateAssumedNil(keys: ["ageLimit", "capacity", "wheelchairAccess"])
    }
}
