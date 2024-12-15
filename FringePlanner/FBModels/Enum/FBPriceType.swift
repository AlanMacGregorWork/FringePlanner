//
//  FBPriceType.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

/// Dictates the cost of the performance
enum FBPriceType: Decodable, Equatable, Hashable {
    case paid
    case free
    case payWhatYouCan
    case other(String)
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        
        switch stringValue {
        case "paid": self = .paid
        case "free": self = .free
        case "pay-what-you-can": self = .payWhatYouCan
        default:
            fringeAssertFailure("Found non-identified price type")
            self = .other(stringValue.trimmed)
        }
    }
}
