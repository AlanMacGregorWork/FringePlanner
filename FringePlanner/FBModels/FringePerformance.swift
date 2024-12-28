//
//  FringePerformance.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/11/2024.
//

import Foundation

struct FringePerformance: Equatable, Hashable {
    let title: String?
    let type: FringePerformanceType
    /// `false` indicates event is drop-in between start and end time
    let isAtFixedTime: Bool
    let priceType: FringePriceType
    let price: Double
    let concession: Double?
    let priceString: String
    let start: Date
    let end: Date
    let durationMinutes: Int
}

extension FringePerformance: Decodable {
    init(from decoder: (any Decoder)) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        type = try container.decode(FringePerformanceType.self, forKey: "type")
        isAtFixedTime = try container.decode(Bool.self, forKey: "isAtFixedTime")
        priceType = try container.decode(FringePriceType.self, forKey: "priceType")
        price = try container.decode(Double.self, forKey: "price")
        concession = try container.decodeIfPresent(Double.self, forKey: "concession")
        priceString = try container.decode(String.self, forKey: "priceString").trimmed
        start = try container.decode(Date.self, forKey: "start")
        end = try container.decode(Date.self, forKey: "end")
        durationMinutes = try container.decode(Int.self, forKey: "durationMinutes")
        title = try container.decodeIfPresent(String.self, forKey: "title")?.trimmed.nilOnEmpty
    }
}
