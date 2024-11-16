//
//  FBVenue.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

import Foundation

/// Contains details of the venue for the performance
struct FBVenue: Equatable {
    let code: String
    let description: String?
    let name: String
    let address: String?
    let position: Position
    let postCode: String
    let webAddress: URL?
    let phone: String?
    let email: String?
    let disabledDescription: String?
}

extension FBVenue: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        self.address = try container.decodeIfPresent(String.self, forKey: "address")?.trimmed.nilOnEmpty
        self.code = try container.decode(String.self, forKey: "code").trimmed
        self.description = try container.decodeIfPresent(String.self, forKey: "description")?.trimmed.nilOnEmpty
        self.name = try container.decode(String.self, forKey: "name").trimmed
        self.position = try container.decode(Position.self, forKey: "position")
        self.postCode = try container.decode(String.self, forKey: "postCode").trimmed
        self.webAddress = try container.decodeIfPresent(String.self, forKey: "webAddress")?.trimmed.nilOnEmpty.map({ URL(string: $0) }) ?? nil
        self.phone = try container.decodeIfPresent(String.self, forKey: "phone")?.trimmed.nilOnEmpty
        self.email = try container.decodeIfPresent(String.self, forKey: "email")?.trimmed.nilOnEmpty
        self.disabledDescription = try container.decodeIfPresent(String.self, forKey: "disabledDescription")?.trimmed.nilOnEmpty
    }
}

extension FBVenue {
    /// The location of the venue
    struct Position: Codable, Equatable {
        let lat: Double
        let lon: Double
    }
}
