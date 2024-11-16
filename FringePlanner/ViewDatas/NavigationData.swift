//
//  NavigationData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/10/2024.
//

import SwiftUI

/// Allows handling navigation
struct NavigationData<RouterType: RouterProtocol, each Content: ViewDataProtocol>: ViewDataProtocol {
    typealias ContentView = NavigationView<repeat each Content>
    let router: RouterType
    @FringeDataResultBuilder let values: (repeat each Content)
    
    struct NavigationView<each T: ViewDataProtocol>: View, ViewProtocol {
        
        // MARK: Property
        
        private let data: NavigationData<RouterType, repeat each T>
        @StateObject private var router: RouterType
        @State private var localSheet: RouterType.NavigationLocation?
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
        
        // MARK: Init
        
        init(data: NavigationData<RouterType, repeat each T>) {
            self.data = data
            self._router = .init(wrappedValue: data.router)
        }
        
        // MARK: Body
        
        var body: some View {
            navigationView
                .onChange(of: router.pushedSheet) { onSheetAdded() }
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
            TupleView((repeat (each data.values).createView()))
                .navigationDestination(for: RouterType.NavigationLocation.self,
                                       destination: { $0.toView() })
        }
        
        // MARK: Content Updates
        
        func onSheetUpdated() {
            // This block of work only updates views if the local & router sheets exist
            guard let routerSheet = router.pushedSheet, let localSheet = localSheet else { return }
            // If a sheet is already presented and is different from the sheet in the router,
            // we need to pop the existing sheet
            guard localSheet != routerSheet else { return }
            pathContainer.path.removeLast(pathContainer.path.count - pathCount + 1)
        }
        
        func onSheetAdded() {
            guard let routerSheet = router.pushedSheet else { return }
            pathContainer.path.append(routerSheet)
            pathCount = pathContainer.path.count
            localSheet = routerSheet
        }
        
        func onChangeNavigationPath() {
            // If the router has a sheet which was made on a path count larger than the current
            // path count, it must already been removed from the path, and it can now be removed.
            guard router.pushedSheet != nil, pathCount > pathContainer.path.count else { return }
            router.pushedSheet = nil
            localSheet = nil
            pathCount = 0
        }
    }
}

// MARK: Equatable Support

extension NavigationData: Equatable {
    /// Note: Custom `Equatable` required due to parameter pack
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.router == rhs.router else { return false }
        for (left, right) in repeat (each lhs.values, each rhs.values) {
            guard left == right else { return false }
        }
        return true
    }
}

// MARK: - Environment Values

private extension EnvironmentValues {
    @Entry var pathContainer: PathContainer?
}

/// Allows the path var to be passed onto child views.
@MainActor
@Observable
private final class PathContainer {
    var path = NavigationPath()
}
