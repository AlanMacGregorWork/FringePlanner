//
//  FBPerformanceType.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

/// Defines how the performance can experienced
enum FBPerformanceType: Decodable, Equatable, Hashable {
    case inPerson
    case other(String)
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self).lowercased()
        
        switch stringValue {
        case "in-person": self = .inPerson
        default:
            fbAssertionFailure("Found non-identified performance type")
            self = .other(stringValue.trimmed)
        }
    }
}
