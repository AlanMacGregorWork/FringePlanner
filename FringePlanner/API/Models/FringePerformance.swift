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
    /// Note: This is not available in the original JSON but is instead pulled in from the custom decoder
    let eventCode: String
}

// MARK: APIFringeModel

extension FringePerformance: APIFringeModel {
    typealias DBFringeModelType = DBFringePerformance
    var referenceID: String { "Performance-\(eventCode)-\(fringeDateFormatter.string(from: start))" }
}

// MARK: Codable

private let kType = "type"
private let kIsAtFixedTime = "isAtFixedTime"
private let kPriceType = "priceType"
private let kPrice = "price"
private let kConcession = "concession"
private let kPriceString = "priceString"
private let kStart = "start"
private let kEnd = "end"
private let kDurationMinutes = "durationMinutes"
private let kTitle = "title"
private let kEventCode = "eventCode"

extension FringePerformance: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        try container.encodeIfPresent(type, forKey: kType)
        try container.encodeIfPresent(isAtFixedTime, forKey: kIsAtFixedTime)
        try container.encodeIfPresent(priceType, forKey: kPriceType)
        try container.encodeIfPresent(price, forKey: kPrice)
        try container.encodeIfPresent(concession, forKey: kConcession)
        try container.encodeIfPresent(priceString, forKey: kPriceString)
        try container.encodeIfPresent(fringeDateFormatter.string(from: start), forKey: kStart)
        try container.encodeIfPresent(fringeDateFormatter.string(from: end), forKey: kEnd)
        try container.encodeIfPresent(durationMinutes, forKey: kDurationMinutes)
        try container.encodeIfPresent(title, forKey: kTitle)
        try container.encodeIfPresent(eventCode, forKey: kEventCode)
    }
    
    init(from decoder: (any Decoder)) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        type = try container.decode(FringePerformanceType.self, forKey: kType)
        isAtFixedTime = try container.decode(Bool.self, forKey: kIsAtFixedTime)
        priceType = try container.decode(FringePriceType.self, forKey: kPriceType)
        price = try container.decode(Double.self, forKey: kPrice)
        concession = try container.decodeIfPresent(Double.self, forKey: kConcession)
        priceString = try container.decode(String.self, forKey: kPriceString).trimmed
        start = try container.decode(Date.self, forKey: kStart)
        end = try container.decode(Date.self, forKey: kEnd)
        durationMinutes = try container.decode(Int.self, forKey: kDurationMinutes)
        title = try container.decodeIfPresent(String.self, forKey: kTitle)?.trimmed.nilOnEmpty
        eventCode = try Self.getCodeValue(from: decoder)
    }

    /// The `FringePerformance` model does not include the `eventCode` required to build a unique `referenceID` so
    /// the decoder must pass the value through its `userInfo`
    private static func getCodeValue(from decoder: any Decoder) throws -> String {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        if let eventCode = try? container.decodeIfPresent(String.self, forKey: kEventCode) {
            // FP-2: This is currently required to validate the encoding of the model but will be removed
            return eventCode
        } else {
            // Access the eventCode through userInfo
            guard let eventCodeKey = JSONDecoder.DecoderStorage.eventCodeKey else {
                throw JSONDecoder.DecoderStorage.DecoderStorageError.keyIsNil }
            guard let eventCodeStorage = decoder.userInfo[eventCodeKey] as? JSONDecoder.DecoderStorage else {
                throw JSONDecoder.DecoderStorage.DecoderStorageError.userInfoValueNotStorage }
            guard let eventCode = eventCodeStorage.value as? String else {
                throw JSONDecoder.DecoderStorage.DecoderStorageError.valueIsNil
            }
            return eventCode
        }
    }
}
