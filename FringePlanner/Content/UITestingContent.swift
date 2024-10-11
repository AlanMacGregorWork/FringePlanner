//
//  UITestingContent.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 11/10/2024.
//

import SwiftUI

#if DEBUG

/// Content used for UI testing
struct UITestingContentContainer {
    class Interaction: InteractionProtocol {
        let router: Router
        
        init(router: Router) {
            self.router = router
        }
        
        func openSheet1() {
            self.router.pushScreen(location: .screen1)
        }
        func openSheet2() {
            self.router.pushScreen(location: .screen2)
        }
    }
    
    class Router: RouterProtocol {
        @Published var navigationPath = NavigationPath()
        
        enum NavigationLocation: NavigationLocationProtocol {
            case screen1
            case screen2
            
            @ViewBuilder
            func toView() -> some View {
                switch self {
                case .screen1: Text("Nav: Screen 1")
                case .screen2: Text("Nav: Screen 2")
                }
            }
        }
        
        func pushScreen(location: NavigationLocation) {
            navigationPath.append(location)
        }
    }
    
    struct Content: ContentProtocol {
        let router: Router
        let interaction: Interaction
        let dataSource = BasicDataSource()
        
        init() {
            let router = Router()
            let interaction = Interaction(router: router)
            self.interaction = interaction
            self.router = router
        }
        
        let structure = { (navigationBinding:Binding<NavigationPath>, interaction :Interaction, dataSource :BasicDataSource) in
            GroupData(routerType: Router.self, type: .navigation(navigationBinding)) {
                GroupData(routerType: Router.self, type: .form) {
                    ButtonData(title: "Open Screen 1", interaction: interaction.openSheet1)
                    ButtonData(title: "Open Screen 2", interaction: interaction.openSheet2)
                }
            }
        }
    }
    
    @ViewBuilder
    var uiTestingView: some View {
        Content().buildView()
    }
}

#endif
