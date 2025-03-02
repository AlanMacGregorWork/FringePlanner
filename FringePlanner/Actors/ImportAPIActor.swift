//
//  ImportAPIActor.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 25/01/2025.
//

import SwiftData
import Foundation

@ModelActor
/// Allows the importing of API models into the database
actor ImportAPIActor {
    
    // MARK: Variables
    
    /// Returns true if any content is awaiting saving
    var hasChanges: Bool {
        return modelContext.hasChanges
    }
    
    // MARK: Database importing

    /// The main entry point for updating the database from the fringe events
    func updateEvents(_ events: [FringeEvent]) throws(DBError) -> [Status] {
        try events.map(update(event:)).flatMap({ $0 })
    }
    
    /// Updates/Adds a single fringe event into the database
    func update(event: FringeEvent) throws(DBError) -> [Status] {
        let venueStatus = try updateModel(from: event.venue)
        let eventStatus = try updateModel(from: event)
        let performanceInputStatuses = try event.performances.map(updateModel(from:))
        let performanceCancelledStatuses = try cancelMissingPerformances(from: event)
        // Return statuses
        return [venueStatus, eventStatus] + performanceInputStatuses + performanceCancelledStatuses
    }

    /// Will insert the model if it does not exist or update if it does exist.
    func updateModel<APIFringeModelType: APIFringeModel>(from apiModel: APIFringeModelType) throws(DBError) -> Status {
        // Get the DB model if it exists
        if let dbModel = try Self.getDBModel(from: apiModel, context: modelContext) {
            // If the models are equal, theres no need to update the database
            if dbModel == apiModel {
                return .noChanges
            }
            // Update the model
            dbModel.update(from: apiModel)
            return .updatedModel(type: APIFringeModelType.DBFringeModelType.self, referenceID: apiModel.referenceID)
        } else {
            return try insertModel(from: apiModel)
        }
    }
    
    /// Insert the model into the Database
    func insertModel<APIFringeModelType: APIFringeModel>(from apiModel: APIFringeModelType) throws(DBError) -> ImportAPIActor.Status {
        // Create a new model and insert it into the database
        let dbModel = try APIFringeModelType.DBFringeModelType(apiModel: apiModel, context: modelContext)
        modelContext.insert(dbModel)
        // There is currently no way to tell if the maintainer has support for the model, and calling `.insert(_)`
        // will not do anything. This will now throw if the model is not inserted as it means saving will fail
        guard dbModel.modelContext != nil else { throw .insertFailed(.modelDidNotInsertIntoContext) }
        return .insertedModel(type: APIFringeModelType.DBFringeModelType.self, referenceID: apiModel.referenceID)
    }
    
    /// Cancels any performances no longer included in the event
    private func cancelMissingPerformances(from event: FringeEvent) throws(DBError) -> [Status] {
        let predicate = newlyCancelledPerformancesPredicate(from: event)
        let cancelledPerformances = try Self.getDBModels(from: predicate, context: modelContext)
        return cancelledPerformances.map({ performance in
            performance.updateStatusToCancelled()
            return Status.updatedModel(type: DBFringePerformance.self, referenceID: performance.referenceID)
        })
    }

    /// Save changes contained inside this context
    func saveChanges() throws(DBError) {
        do {
            try modelContext.save()
        } catch {
            fringeAssertFailure("Database save failed")
            throw .saveFailed
        }
    }
    
    /// Retrieves the corresponding database model for the api model
    static func getDBModel<APIFringeModelType: APIFringeModel>(from apiModel: APIFringeModelType, context: ModelContext) throws(DBError) -> APIFringeModelType.DBFringeModelType? {
        let predicate = APIFringeModelType.DBFringeModelType.predicate(forMatchingAPIModel: apiModel)
        return try getDBModel(from: predicate, context: context)
    }
    
    /// Retrieves the corresponding database model for the api model
    static func getDBModel<DBFringeModelType: DBFringeModel>(from predicate: Predicate<DBFringeModelType>, context: ModelContext) throws(DBError) -> DBFringeModelType? {
        // Get models from database
        let allDBModels = try getDBModels(from: predicate, context: context)
        
        // Ensure that no more than one more model is found as the the response should be unique.
        guard allDBModels.count <= 1 else {
            fringeAssertFailure("Found multiple models with the same id")
            throw DBError.assumptionFailed(.multipleModelsForSingle)
        }
        return allDBModels.first
    }
    
    /// Retrieves the corresponding database model for the api model
    static func getDBModels<DBFringeModelType: DBFringeModel>(from predicate: Predicate<DBFringeModelType>, context: ModelContext) throws(DBError) -> [DBFringeModelType] {
        let descriptor = FetchDescriptor(predicate: predicate)
        do {
            return try context.fetch(descriptor)
        } catch {
            fringeAssertFailure("Database fetch failed")
            throw DBError.fetchFailed
        }
    }
}

// MARK: - Predicates

/// Predicate to find performances that are no longer active
private func newlyCancelledPerformancesPredicate(from event: FringeEvent) -> Predicate<DBFringePerformance> {
    let eventCode = event.code
    let performanceStartDates = event.performances.map(\.start)
    let activePredicate = DBFringePerformance.predicate(for: .active)
    
    return #Predicate<DBFringePerformance> { dbPerformance in
        // The performance must be for this event
        dbPerformance.eventCode == eventCode &&
        // The performance must not be included in the input performances
        !performanceStartDates.contains(dbPerformance.start) &&
        // The performance must previously have previously been active
        activePredicate.evaluate(dbPerformance)
    }
}

// MARK: Enums

extension ImportAPIActor {
    /// Indicates what took place when adding the API content to the database
    enum Status: Equatable, Hashable {
        case noChanges
        case insertedModel(type: String, referenceID: String)
        case updatedModel(type: String, referenceID: String)
        
        /// Helper function to convert the type into a String
        static func insertedModel<DBFringeModelType: DBFringeModel>(type modelType: DBFringeModelType.Type, referenceID: String) -> Self {
            .insertedModel(type: "\(modelType)", referenceID: referenceID)
        }
        
        /// Helper function to convert the type into a String
        static func updatedModel<DBFringeModelType: DBFringeModel>(type modelType: DBFringeModelType.Type, referenceID: String) -> Self {
            .updatedModel(type: "\(modelType)", referenceID: referenceID)
        }
    }
}
