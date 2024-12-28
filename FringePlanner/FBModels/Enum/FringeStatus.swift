//
//  FringeStatus.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

/// Defines the status of a Fringe event
enum FringeStatus: Decodable {
    case active
    case cancelled
    /// Note: If this appears in a response the event should be deleted from the local database
    case deleted
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try container.decode(String.self).lowercased()
        
        switch status {
        case "active": self = .active
        case "cancelled": self = .cancelled
        case "deleted": self = .deleted
        default: self = .active // Default to `active` if unknown status
        }
    }
}
