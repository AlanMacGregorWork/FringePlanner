//
//  NavigationData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/10/2024.
//

import SwiftUI

/// Allows handling navigation
struct NavigationData<Content: ViewDataProtocol>: ViewDataProtocol {
    typealias ContentView = NavigationView
    let container: Content
    let title: String?
    let toolbarItems: [NavigationToolbarItem]
    
    init(title: String? = nil, toolbarItems: [NavigationToolbarItem] = [], @FringeDataResultBuilder _ values: () -> Content) {
        self.container = values()
        self.title = title
        self.toolbarItems = toolbarItems
    }
    
    struct NavigationView: View, ViewProtocol {
        
        // MARK: Property
        
        private let data: NavigationData<Content>
        @State private var localSheet: (any NavigationLocationProtocol)?
        /// The path count given on the last push. This can be used to identify if the view has been popped and
        /// the sheet needs to be set to nil.
        @State private var pathCount = 0
        
        // MARK: Property (Path Containing)
        
        // There should be a single source of truth for the `PathContainer`. To support this a state and environment
        // version of the object are created, which return a coalesce of the environment variable (which can be nil),
        // or failing that, the state variable
        private var pathContainer: PathContainer { envPath ?? statePath }
        @Environment(\.pathContainer) private var envPath: PathContainer?
        @State private var statePath = PathContainer()
        @Environment(\.router) private var router: RouterProtocolWrapper
        
        // MARK: Init
        
        init(data: NavigationData<Content>) {
            self.data = data
        }
        
        // MARK: Body
        
        var body: some View {
            navigationView
                .onChange(of: pathContainer.path) { onChangeNavigationPath() }
                .onReceive(router.objectWillChange, perform: { _ in onSheetUpdated() })
        }
        
        /// Will either return the navigation stack or just the content based on whether the stack already exists
        @ViewBuilder
        private var navigationView: some View {
            // If the environment value does not exist, it means the this view is not in a
            // navigation stack, and that it can be created.
            if envPath == nil {
                NavigationStack(path: $statePath.path) {
                    content
                }
                .environment(\.pathContainer, statePath)
            } else {
                // This view is already in a navigation stack and a new one does not need to be added
                content
            }
        }
        
        /// The content to include in the navigation view
        private var content: some View {
            data.container.createView()
                .modifier(NavigationDestinationModifier(router: router))
                // Adds toolbar items from the NavigationData to the view
                .toolbar {
                    ForEach(data.toolbarItems) { toolBarItem in
                        toolBarItem.content()
                    }
                }
                // Adds a title
                .withContent(data.title, transform: { $0.navigationTitle($1) })
        }
        
        // MARK: Content Updates
        
        private func onSheetUpdated() {
            guard let routerSheet = router.pushedSheet else { return }

            // If a sheet is already presented and is different from the sheet in the router,
            // we need to pop the existing sheet
            if router.shouldPopExistingSheet(localSheet) {
                pathContainer.path.removeLast(pathContainer.path.count - pathCount + 1)
            }
            
            // Add the new sheet add onto the path container
            pathContainer.path.append(routerSheet)
            pathCount = pathContainer.path.count
            localSheet = routerSheet
        }

        private func onChangeNavigationPath() {
            // If the router has a sheet which was made on a path count larger than the current
            // path count, it must already been removed from the path, and it can now be removed.
            guard router.pushedSheet != nil, pathCount > pathContainer.path.count else { return }
            router.clearPushedSheet()
            localSheet = nil
            pathCount = 0
        }
    }
}

// MARK: - Environment Values

private extension EnvironmentValues {
    @Entry var pathContainer: PathContainer?
}

/// Allows the path var to be passed onto child views.
@Observable
private final class PathContainer {
    var path = NavigationPath()
}

// MARK: - ToolbarItem

/// A structure representing an item to be displayed in a navigation toolbar.
/// Provides a standardized way to create and manage toolbar items across the application.
struct NavigationToolbarItem: Identifiable {
    let id = UUID()
    /// The content to be displayed in the toolbar item
    let content: (() -> AnyView)
}

extension NavigationToolbarItem {
    /// Creates a favorite/unfavorite toolbar button
    /// - Parameters:
    ///   - isFavourite: Boolean indicating whether the item is currently favorited
    ///   - onTap: Closure to execute when the button is tapped
    /// - Returns: A configured `NavigationToolbarItem` for toggling favorite status
    static func favourite(isFavourite: Bool, onTap: @escaping (() -> Void)) -> Self {
        NavigationToolbarItem {
            AnyView(
                Button(action: onTap) {
                    Image.favourite(isFavourite: isFavourite)
                }
            )
        }
    }
}

// MARK: - Navigation Destination Modifier

/// A modifier that conditionally adds a navigation destination based on the navigation location type
private struct NavigationDestinationModifier: ViewModifier {
    let router: RouterProtocolWrapper
    
    func body(content: Content) -> some View {
        return router.setupNavigationDestination(for: content)
    }
}
