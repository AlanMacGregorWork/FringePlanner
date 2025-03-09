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

// Note: Codable is predominantly used from decoding the JSON from the API however SwiftData has issues with this
// so relies on the `RawRepresentable` for its reading & writing

extension FringeStatus: Codable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try container.decode(String.self).lowercased()
        self = .init(rawValue: status) ?? .active // Default to `active` if unknown status
    }
}

// MARK: RawRepresentable

private let kActive = "active"
private let kCancelled = "cancelled"
private let kDeleted = "deleted"

extension FringeStatus: RawRepresentable {
    init?(rawValue: String) {
        switch rawValue {
        case kActive: self = .active
        case kCancelled: self = .cancelled
        case kDeleted: self = .deleted
        default:
            fringeAssertFailure("Found non-identified status type")
            self = .active // Default to `active` if unknown status
        }
    }
    
    var rawValue: String {
        switch self {
        case .active: return kActive
        case .cancelled: return kCancelled
        case .deleted: return kDeleted
        }
    }
}
