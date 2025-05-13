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

    /// Returns a single expected performance
    static func performance(referenceID: String) -> SingleContainer<DBFringePerformance> {
        // Swift Predicates don't support String concats required to build the reference id. To get around it,
        // the values that build the referenceID are created instead.
        
        // Split the referenceID into components
        let components = referenceID.split(separator: "-")
        
        // Ensure we have the expected format: "Performance-eventCode-timestamp" where eventCode may contain hyphens
        guard components.count >= 3, 
              components[0] == "Performance",
              let lastComponent = components.last,
              let timeInterval = TimeInterval(lastComponent) else {
            // Return a predicate that won't match anything if the format is invalid
            fringeAssertFailure("ReferenceID is invalid")
            return .init(predicate: #Predicate<DBFringePerformance> { _ in false })
        }
                
        // Extract eventCode by taking all components between the first and last and joining them with hyphens
        let eventCodeComponents = components[1..<(components.count-1)]
        let eventCode = eventCodeComponents.joined(separator: "-")
        
        // Create a filter from the values
        let startDate = Date(timeIntervalSince1970: timeInterval)
        return .init(predicate: #Predicate<DBFringePerformance> { performance in
            performance.eventCode == eventCode && performance.start == startDate
        })
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
