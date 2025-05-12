//
//  PredicateHelper.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 26/04/2025.
//

import Foundation
import SwiftData

/// Contains helper functions for creating containers for database queries
struct PredicateHelper {
    private init() {}

    /// Returns a single expected event
    static func event(eventCode: String) -> SingleContainer<DBFringeEvent> {
        return .init(predicate: #Predicate<DBFringeEvent> { $0.code == eventCode })
    }
}

// MARK: - Container Protocol

extension PredicateHelper {
    protocol ContainerProtocol {
        associatedtype DatabaseModelType: PersistentModel & DBFringeModel
        associatedtype ReturnedType
        var predicate: Predicate<DatabaseModelType> { get }
        func getContent(context: ModelContext) throws(DBError) -> ReturnedType
    }   
}

extension PredicateHelper.ContainerProtocol {
    /// Returns the throwable value as a `Result`
    func getWrappedContent(context: ModelContext) -> Result<ReturnedType, DBError> {
        do {
            return .success(try self.getContent(context: context))
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - Container Types

extension PredicateHelper {
    // A container for a single expected object
    struct SingleContainer<DatabaseModelType: DBFringeModel>: ContainerProtocol {
        typealias ReturnedType = DatabaseModelType
        let predicate: Predicate<DatabaseModelType>
        
        func getContent(context: ModelContext) throws(DBError) -> DatabaseModelType {
            let multipleContainer = MultipleContainer(predicate: predicate)
            guard let firstModel = try multipleContainer.getContent(context: context).first else {
                throw .fetchFailed
            }
            return firstModel
        }
    }

    // A container for a multiple expected objects
    struct MultipleContainer<DatabaseModelType: DBFringeModel>: ContainerProtocol {
        typealias ReturnedType = [DatabaseModelType]
        let predicate: Predicate<DatabaseModelType>
        
        func getContent(context: ModelContext) throws(DBError) -> [DatabaseModelType] {
            return try DBHelper.getDBModels(from: predicate, context: context)
        }
    }
}

// MARK: - Result Extension

private extension Result {
    // A helper function for initializing a Result from a container
    init<Container: PredicateHelper.ContainerProtocol>(
        container: Container,
        context: ModelContext
    ) where Success == Container.ReturnedType, Failure == DBError {
        do {
            self = .success(try container.getContent(context: context))
        } catch {
            self = .failure(error)
        }
    }
}
