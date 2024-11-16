//
//  FBPriceType.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

/// Dictates the cost of the performance
enum FBPriceType: Decodable, Equatable {
    case paid
    case free
    case other(String)
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        
        switch stringValue {
        case "paid": self = .paid
        case "free": self = .free
        default:
            fbAssertionFailure("Found non-identified price type")
            self = .other(stringValue.trimmed)
        }
    }
}
