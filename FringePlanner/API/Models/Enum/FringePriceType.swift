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

private let kPaid = "paid"
private let kFree = "free"
private let kPayWhatYouCan = "pay-what-you-can"

extension FringePriceType: Codable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let stringValue = switch self {
        case .paid: kPaid
        case .free: kFree
        case .payWhatYouCan: kPayWhatYouCan
        case .other(let value): value
        }
        try container.encode(stringValue)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        
        switch stringValue {
        case kPaid: self = .paid
        case kFree: self = .free
        case kPayWhatYouCan: self = .payWhatYouCan
        default:
            fringeAssertFailure("Found non-identified price type")
            self = .other(stringValue.trimmed)
        }
    }
}
