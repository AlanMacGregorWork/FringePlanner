//
//  ArchitectureProtocols.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/10/2024.
//

import SwiftUI

// MARK: - Main

/// Defines the individual components required to build a view
protocol ContentProtocol {
    associatedtype RouterType: RouterProtocol
    associatedtype InteractionType: InteractionProtocol
    associatedtype DataSourceType: DataSourceProtocol
    associatedtype ContentType: ViewDataProtocol
    var router: RouterType { get }
    var interaction: InteractionType { get }
    var dataSource: DataSourceType { get }
    var structure: (Binding<NavigationPath>, RouterType, InteractionType, DataSourceType) -> ContentType { get }
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
