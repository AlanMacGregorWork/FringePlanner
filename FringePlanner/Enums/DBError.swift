//
//  DBError.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 11/01/2025.
//

/// An error for a task made on the database
enum DBError: Error, CustomStringConvertible {
    case fetchFailed
    case saveFailed
    case assumptionFailed(AssumptionFailedReasons)
    
    var description: String {
        switch self {
        case .fetchFailed: return "Database fetch failed"
        case .saveFailed: return "Database save failed"
        case .assumptionFailed(.expectedCreatedVenue): return "Expected created venue not found"
        case .assumptionFailed(.multipleModelsForSingle): return "Found multiple models when expecting single model"
        }
    }
}

// MARK: SubErrors

extension DBError {
    /// Specific errors for actions that should have been carried out successfully
    enum AssumptionFailedReasons {
        case expectedCreatedVenue
        case multipleModelsForSingle
    }
}
