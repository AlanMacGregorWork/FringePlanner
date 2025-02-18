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
    func updateEvents(_ events: [FringeEvent]) async throws(DBError) -> [Status] {
        let venues = Set(events.map(\.venue)) // Set used to avoid attempting to import duplicate models
        return try venues.map(updateModel(from:)) + events.map(updateModel(from:))
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
        let descriptor = FetchDescriptor(predicate: predicate)
        
        // Get models from database
        let allDBModels: [DBFringeModelType]
        do {
            allDBModels = try context.fetch(descriptor)
        } catch {
            fringeAssertFailure("Database fetch failed")
            throw DBError.fetchFailed
        }
        
        // Ensure that no more than one more model is found as the the response should be unique.
        guard allDBModels.count <= 1 else {
            fringeAssertFailure("Found multiple models with the same id")
            throw DBError.assumptionFailed(.multipleModelsForSingle)
        }
        return allDBModels.first
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
