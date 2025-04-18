//
//  ArchitectureProtocols.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/10/2024.
//

import SwiftUI
import Combine
import SwiftData

// MARK: - Main

/// Defines the individual components required to build a view
protocol ContentProtocol {
    associatedtype RouterType: RouterProtocol
    associatedtype InteractionType: InteractionProtocol
    associatedtype DataSourceType: DataSourceProtocol
    associatedtype Structure: StructureProtocol where Structure.Content == Self
    var router: RouterType { get }
    var interaction: InteractionType { get }
    var dataSource: DataSourceType { get }
}

// MARK: - Components

/// Allows access to navigation
protocol RouterProtocol: Observable, Equatable {
    associatedtype NavigationLocation: NavigationLocationProtocol
    var pushedSheet: NavigationLocation? { get set }
    var objectWillChange: PassthroughSubject<Void, Never> { get }
    /// Reference to the helper that provides dependencies for view construction and navigation
    var constructionHelper: ConstructionHelper { get }
}

/// Contains interactions and events from the user.
protocol InteractionProtocol { }

/// The source of data to derive the content
protocol DataSourceProtocol: Observable, AnyObject { }

/// A structure that is not bound to any `ContentProtocol` type
protocol BaseStructureProtocol {
    @MainActor
    var structure: StructureType { get }
    associatedtype StructureType: ViewDataProtocol
}
    
/// A structure that can be initialised from the `ContentProtocol` type
protocol StructureProtocol: BaseStructureProtocol {
    associatedtype Content: ContentProtocol
    init(input: Content)
}

// MARK: - Associated Types For Components

/// Identifies a hashable type that can be sent and received for navigation
protocol NavigationLocationProtocol: Hashable {
    associatedtype ContentView: View
    /// A view that van be generated from the location
    @ViewBuilder
    @MainActor
    func toView(constructionHelper: ConstructionHelper) -> ContentView
}

// MARK: - Helpers

@Observable
/// Simplifies the router creation when just requiring the location type
final class SimplifiedRouter<NavigationLocation: NavigationLocationProtocol>: RouterProtocol, Hashable {
    let objectWillChange = PassthroughSubject<Void, Never>()
    /// Helper that provides dependencies for constructing views during navigation
    let constructionHelper: ConstructionHelper
    
    /// Initializes router with necessary dependencies
    /// - Parameter constructionHelper: The helper containing dependencies for view construction
    init(constructionHelper: ConstructionHelper) {
        self.constructionHelper = constructionHelper
    }
    
    var pushedSheet: NavigationLocation? {
        didSet {
            objectWillChange.send(())
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pushedSheet)
    }
    
    static func == (lhs: SimplifiedRouter, rhs: SimplifiedRouter) -> Bool {
        lhs.pushedSheet == rhs.pushedSheet
    }
    
    func pushSheet(location: NavigationLocation?) {
        self.pushedSheet = location
    }
}

/// A helper struct used to provide necessary dependencies for constructing views in the application architecture.
/// This allows passing critical resources throughout the navigation and view generation processes.
struct ConstructionHelper {
    /// The SwiftData model container that provides access to the app's persistent storage
    /// Used by views and other components to access and modify model data
    let modelContainer: ModelContainer
}
