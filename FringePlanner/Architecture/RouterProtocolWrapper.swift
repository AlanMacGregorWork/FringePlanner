//
//  RouterProtocolWrapper.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 24/05/2025.
//

import Combine
import SwiftUI

/// Allows type erasing of the router protocol
struct RouterProtocolWrapper {

    // MARK: Properties
    
    let objectWillChange: PassthroughSubject<Void, Never>
    let clearPushedSheet: () -> Void
    var pushedSheet: (any NavigationLocationProtocol)? { self._pushedSheet() }
    private let _setupNavigationDestination: (any View) -> AnyView
    private let _shouldPopExistingSheet: (any NavigationLocationProtocol) -> Bool
    private let _pushedSheet: (() -> (any NavigationLocationProtocol)?)

    // MARK: Init

    @MainActor
    init<RouterType: RouterProtocol>(_ router: RouterType) {
        let constructionHelper = router.constructionHelper
        
        self.objectWillChange = router.objectWillChange
        self.clearPushedSheet = { router.pushedSheet = nil }
        self._setupNavigationDestination = { content in
            //  `BasicNavigationLocation` is the default navigation location type for the application with no navigation
            // destinations, this modifier ensures it is not added to the view as adding multiple navigation
            // destinations to a view will cause a runtime error.
            guard RouterType.NavigationLocation.self != BasicNavigationLocation.self else { return AnyView(content) }
            
            // Router is using custom navigation so its destinations should be set
            return AnyView(content.navigationDestination(for: RouterType.NavigationLocation.self) { location in
                location.toView(constructionHelper: constructionHelper)
            })
        }
        self._shouldPopExistingSheet = { existingSheet in
            guard let existingSheet = existingSheet as? RouterType.NavigationLocation else { return false }
            guard let sheet = router.pushedSheet else { return false }
            // The existing sheet is not the current sheet in the router, the existing sheet should now be removed
            // if it appears after the current router sheet
            return existingSheet != sheet
        }
        self._pushedSheet = { router.pushedSheet }
    }
    
    fileprivate init() {
        self.objectWillChange = .init()
        self.clearPushedSheet = {}
        self._setupNavigationDestination = { AnyView($0) }
        self._shouldPopExistingSheet = { _ in false }
        self._pushedSheet = { nil }
    }

    // MARK: Functions
    
    /// Sets up the navigation destination for the provided content view.
    func setupNavigationDestination<Content: View>(for content: Content) -> some View {
        _setupNavigationDestination(content)
    }
    
    /// Determines if an existing sheet should be popped based on the provided sheet.
    func shouldPopExistingSheet(_ existingSheet: (any NavigationLocationProtocol)?) -> Bool {
        guard let existingSheet else { return false }
        return _shouldPopExistingSheet(existingSheet)
    }
}

// MARK: - EnvironmentValues

extension EnvironmentValues {
    @Entry var router = RouterProtocolWrapper()
}
