//
//  FringeStatus.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/11/2024.
//

/// Defines the status of a Fringe event
enum FringeStatus {
    case active
    case cancelled
    /// Note: If this appears in a response the event should be deleted from the local database
    case deleted
}

// MARK: Codable

private let kActive = "active"
private let kCancelled = "cancelled"
private let kDeleted = "deleted"

extension FringeStatus: Codable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let stringValue = switch self {
        case .active: kActive
        case .cancelled: kCancelled
        case .deleted: kDeleted
        }
        try container.encode(stringValue)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try container.decode(String.self).lowercased()
        
        switch status {
        case kActive: self = .active
        case kCancelled: self = .cancelled
        case kDeleted: self = .deleted
        default: self = .active // Default to `active` if unknown status
        }
    }
}
