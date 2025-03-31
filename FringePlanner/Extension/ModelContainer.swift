//
//  ModelContainer.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 31/03/2025.
//

import SwiftData

// MARK: - Creation

extension ModelContainer {
    enum CreateError: Error {
        case failedToCreateContainer
    }
    
    /// Returns a new container specific to the model configuration
    static func create() throws(CreateError) -> ModelContainer {
        do {
            let container = try ModelContainer(
                for: DBFringeEvent.self, DBFringeVenue.self, DBFringePerformance.self,
                configurations: Self.modelConfiguration)
            return container
        } catch {
            fringeAssertFailure("Failed to setup container")
            throw .failedToCreateContainer
        }
    }
    
    private static var modelConfiguration: ModelConfiguration {
        switch ApplicationEnvironment.current {
        case .preview, .testingUI, .testingUnit:
            return ModelConfiguration(isStoredInMemoryOnly: true)
        case .normal:
            return ModelConfiguration()
        }
    }
}
