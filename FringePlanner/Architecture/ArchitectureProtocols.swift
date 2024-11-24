//
//  ArchitectureProtocols.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/10/2024.
//

import SwiftUI
import Combine

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
protocol RouterProtocol: Observable, Equatable {
    associatedtype NavigationLocation: NavigationLocationProtocol
    var pushedSheet: NavigationLocation? { get set }
    var objectWillChange: PassthroughSubject<Void, Never> { get }
}

/// Contains interactions and events from the user.
protocol InteractionProtocol { }

/// The source of data to derive the content
protocol DataSourceProtocol: Observable, AnyObject { }

// MARK: - Associated Types For Components

/// Identifies a hashable type that can be sent and received for navigation
protocol NavigationLocationProtocol: Hashable {
    associatedtype ContentView: View
    /// A view that van be generated from the location
    @ViewBuilder
    @MainActor
    func toView() -> ContentView
}

// MARK: - Helpers

/// Contains the models required to build content for `ContentProtocol.structure`
struct ContentViewGenerationInput<Content: BaseContentProtocol> {
    let router: Content.RouterType
    let dataSource: Content.DataSourceType
    let interaction: Content.InteractionType
    let reference: Content
}

@Observable
/// Simplifies the router creation when just requiring the location type
final class SimplifiedRouter<NavigationLocation: NavigationLocationProtocol>: RouterProtocol, Hashable {
    let objectWillChange = PassthroughSubject<Void, Never>()
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
