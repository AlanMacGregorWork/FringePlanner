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

private let kInPerson = "in-person"
private let kOnlineLive = "online-live"
private let kOnlineOnDemand = "online-on-demand"

extension FringePerformanceType: Codable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let stringValue = switch self {
        case .inPerson: kInPerson
        case .onlineLive: kOnlineLive
        case .onlineOnDemand: kOnlineOnDemand
        case .other(let value): value
        }
        try container.encode(stringValue)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self).lowercased()
        
        switch stringValue {
        case kInPerson: self = .inPerson
        case kOnlineLive: self = .onlineLive
        case kOnlineOnDemand: self = .onlineOnDemand
        default:
            fringeAssertFailure("Found non-identified performance type")
            self = .other(stringValue.trimmed)
        }
    }
}
