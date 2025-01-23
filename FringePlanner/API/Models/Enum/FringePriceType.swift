//
//  FringePriceType.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

/// Dictates the cost of the performance
enum FringePriceType: Equatable, Hashable {
    case paid
    case free
    case payWhatYouCan
    case other(String)
}

// MARK: Codable

// Note: Codable is predominantly used from decoding the JSON from the API however SwiftData has issues with this
// so relies on the `RawRepresentable` for its reading & writing

extension FringePriceType: Codable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        self = .init(rawValue: stringValue) ?? .other(stringValue)
    }
}

// MARK: RawRepresentable

private let kPaid = "paid"
private let kFree = "free"
private let kPayWhatYouCan = "pay-what-you-can"

extension FringePriceType: RawRepresentable {
    init?(rawValue: String) {
        switch rawValue {
        case kPaid: self = .paid
        case kFree: self = .free
        case kPayWhatYouCan: self = .payWhatYouCan
        default:
            fringeAssertFailure("Found non-identified price type")
            self = .other(rawValue.trimmed)
        }
    }
    
    var rawValue: String {
        switch self {
        case .paid: return kPaid
        case .free: return kFree
        case .payWhatYouCan: return kPayWhatYouCan
        case .other(let value): return value
        }
    }
}
