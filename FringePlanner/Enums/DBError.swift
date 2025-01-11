//
//  DBError.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 11/01/2025.
//

/// An error for a task made on the database
enum DBError: Error, CustomStringConvertible {
    case updateFailed
    case fetchFailed
    case insertFailed
    
    var description: String {
        switch self {
        case .updateFailed: return "Database update failed"
        case .fetchFailed: return "Database fetch failed"
        case .insertFailed: return "Database insert failed"
        }
    }
}
