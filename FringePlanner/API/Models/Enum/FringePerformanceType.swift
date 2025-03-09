//
//  FringePerformanceType.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

/// Defines how the performance can experienced
enum FringePerformanceType: Equatable, Hashable {
    case inPerson
    case onlineLive
    case onlineOnDemand
    case other(String)
}

// MARK: Codable

// Note: Codable is predominantly used from decoding the JSON from the API however SwiftData has issues with this
// so relies on the `RawRepresentable` for its reading & writing

extension FringePerformanceType: Codable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self).lowercased()
        self = .init(rawValue: stringValue) ?? .other(stringValue)
    }
}

// MARK: RawRepresentable

private let kInPerson = "in-person"
private let kOnlineLive = "online-live"
private let kOnlineOnDemand = "online-on-demand"

extension FringePerformanceType: RawRepresentable {
    init?(rawValue: String) {
        switch rawValue {
        case kInPerson: self = .inPerson
        case kOnlineLive: self = .onlineLive
        case kOnlineOnDemand: self = .onlineOnDemand
        default:
            fringeAssertFailure("Found non-identified performance type")
            self = .other(rawValue.trimmed)
        }
    }
    
    var rawValue: String {
        switch self {
        case .inPerson: kInPerson
        case .onlineLive: kOnlineLive
        case .onlineOnDemand: kOnlineOnDemand
        case .other(let value): value
        }
    }
}
