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
}

// MARK: - Components

/// Allows access to navigation
protocol RouterProtocol where Self: ObservableObject {
    associatedtype NavigationLocation: NavigationLocationProtocol
    var navigationPath: NavigationPath { get set }
}

/// Contains interactions and events from the used.
protocol InteractionProtocol where Self: ObservableObject { }

/// The source of data to derive the content
protocol DataSourceProtocol where Self: ObservableObject { }

// MARK: - Associated Types For Components

/// Identifies a hashable type that can be sent and received for navigation
protocol NavigationLocationProtocol: Hashable {
    associatedtype ContentView: View
    /// A view that van be generated from the location
    @ViewBuilder func toView() -> ContentView
}

// MARK: - Helpers

/// Contains the models required to build content for `ContentProtocol.structure`
struct ContentViewGenerationInput<Content: BaseContentProtocol> {
    let router: Content.RouterType
    let dataSource: Content.DataSourceType
    let interaction: Content.InteractionType
    let navigationPath: Binding<NavigationPath>
}
