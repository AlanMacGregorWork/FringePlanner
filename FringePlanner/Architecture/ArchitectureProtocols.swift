//
//  ArchitectureProtocols.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/10/2024.
//

import SwiftUI

// MARK: - Main

/// Defines the individual components required to build a view
protocol BaseContentProtocol {
    associatedtype RouterType: RouterProtocol
    associatedtype InteractionType: InteractionProtocol
    associatedtype DataSourceType: DataSourceProtocol
    var router: RouterType { get }
    var interaction: InteractionType { get }
    var dataSource: DataSourceType { get }
}

/// Defines the generation of the content
///  - Note: Having this separate to `BaseContentProtocol` allows the `structure` to build the `ContentInput`
/// without having to specify types
protocol ContentProtocol: BaseContentProtocol {
    associatedtype ContentType: ViewDataProtocol
    var structure: (ContentInput) -> ContentType { get }
}

extension ContentProtocol {
    typealias ContentInput = ContentViewGenerationInput<Self>
    
    /// Generates the structure using self as the input
    func generateStructure() -> ContentType {
        self.structure(.init(router: router, dataSource: dataSource, interaction: interaction, reference: self))
    }
}

// MARK: - Components

/// Allows access to navigation
protocol RouterProtocol where Self: BaseRouter<NavigationLocation>, Self: ObservableObject, Self: Equatable {
    associatedtype NavigationLocation: NavigationLocationProtocol
    var pushedSheet: NavigationLocation? { get set }
}

extension RouterProtocol {
    /// Basic Equatable support for the router protocol
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.pushedSheet == rhs.pushedSheet
    }
}

/// Contains interactions and events from the used.
protocol InteractionProtocol where Self: BaseInteraction { }

/// The source of data to derive the content
protocol DataSourceProtocol where Self: ObservableObject { }

// MARK: - Associated Types For Components

/// Identifies a hashable type that can be sent and received for navigation
protocol NavigationLocationProtocol: Hashable {
    associatedtype ContentView: View
    /// A view that van be generated from the location
    @ViewBuilder func toView() -> ContentView
}

// MARK: - Base Components

/// The base class required for interactions
class BaseInteraction: ObservableObject, Equatable {
    static func == (lhs: BaseInteraction, rhs: BaseInteraction) -> Bool {
        // Interactions should not hold state
        return true
    }
}

/// The base class required for router
class BaseRouter<NavigationLocation: NavigationLocationProtocol> {
    @Published var pushedSheet: NavigationLocation?
    
    func pushSheet(location: NavigationLocation?) {
        pushedSheet = location
    }
}

// MARK: - Helpers

/// Contains the models required to build content for `ContentProtocol.structure`
struct ContentViewGenerationInput<Content: BaseContentProtocol> {
    let router: Content.RouterType
    let dataSource: Content.DataSourceType
    let interaction: Content.InteractionType
    let reference: Content
}

/// Simplifies the router creation when just requiring the location type
final class SimplifiedRouter<NavigationLocation: NavigationLocationProtocol>: BaseRouter<NavigationLocation>, RouterProtocol, Hashable {
    func hash(into hasher: inout Hasher) {
        // No hashing needed
    }
}
