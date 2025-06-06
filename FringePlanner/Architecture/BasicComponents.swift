//
//  BasicComponents.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/10/2024.
//

import SwiftUI

// Components that perform no actions

struct BasicInteraction: InteractionProtocol {}

@Observable
class BasicDataSource: DataSourceProtocol {}

/// Enum with no cases meaning no valid selection can be triggered
enum BasicNavigationLocation: NavigationLocationProtocol {
    // Without a case, we can always refuse the UI
    func toView(constructionHelper: ConstructionHelper) -> some View { EmptyView() }
}
