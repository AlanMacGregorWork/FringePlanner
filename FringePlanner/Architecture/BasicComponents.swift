//
//  BasicComponents.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/10/2024.
//

import SwiftUI

// Components that perform no actions

class BasicRouter: RouterProtocol, ObservableObject {
    // Enum with no cases meaning no valid selection can be triggered
    enum NavigationLocation: NavigationLocationProtocol {
        // Without a case, we can always refuse the UI
        func toView() -> some View { EmptyView() }
    }
    @Published var navigationPath = NavigationPath()
}

class BasicInteraction: InteractionProtocol, ObservableObject {}

class BasicDataSource: DataSourceProtocol, ObservableObject {}
