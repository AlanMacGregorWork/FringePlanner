//
//  DBError.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 11/01/2025.
//

/// An error for a task made on the database
enum DBError: Error, Equatable {
    case fetchFailed
    case saveFailed
    case insertFailed(InsertFailedReason)
    case assumptionFailed(AssumptionFailedReasons)
}

// MARK: CustomStringConvertible

extension DBError: CustomStringConvertible {
    var description: String {
        switch self {
        case .fetchFailed: return "Database fetch failed"
        case .saveFailed: return "Database save failed"
        case .assumptionFailed(.expectedCreatedVenue): return "Expected created venue not found"
        case .assumptionFailed(.multipleModelsForSingle): return "Found multiple models when expecting single model"
        case .insertFailed(.modelDidNotInsertIntoContext): return "Failed to insert model into the context. The model type may not be set for use with the ModelContainer"
        }
    }
}

// MARK: SubErrors

extension DBError {
    /// Specific errors for actions that should have been carried out successfully
    enum AssumptionFailedReasons: Equatable {
        case expectedCreatedVenue
        case multipleModelsForSingle
    }
    
    /// An insertion action failure
    enum InsertFailedReason: Equatable {
        case modelDidNotInsertIntoContext
    }
}
