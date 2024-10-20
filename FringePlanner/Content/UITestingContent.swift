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
    class Interaction: BaseInteraction, InteractionProtocol {
        let router: Router
        
        init(router: Router) {
            self.router = router
        }
        
        func push(sheet: Router.NavigationLocation) {
            self.router.pushScreen(location: sheet)
        }
        
        func pushNavigationTestsSheet() {
            self.router.pushScreen(location: .navigationTests)
        }
    }
    
    class Router: SimplifiedRouter<Router.NavigationLocation> {
        enum NavigationLocation: NavigationLocationProtocol {
            case navigationTests
            
            @ViewBuilder
            func toView() -> some View {
                NavigationTestSheetAContainer.Content().buildView()
            }
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
        
        let structure = { (input: ContentInput) in
            NavigationData(router: input.router) {
                TextData(text: "Title: Main Sheet")
                GroupData(type: .form) {
                    GroupData(type: .section) {
                        ButtonData(title: "Navigation Tests", interaction: input.interaction.pushNavigationTestsSheet)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var uiTestingView: some View {
        Content().buildView()
    }
    
    private struct NavigationTestSheetAContainer {
        class Router: SimplifiedRouter<Router.NavigationLocation> {
            enum NavigationLocation: NavigationLocationProtocol, CaseIterable {
                case sheetBV1
                case sheetBV2
                
                @ViewBuilder
                func toView() -> some View {
                    switch self {
                    case .sheetBV1:
                        NavigationTestSheetBContainer.Content().buildView()
                    case .sheetBV2:
                        Text("Title: Sheet B (V1)")
                    }
                }
            }
        }
        struct Content: ContentProtocol {
            let router = Router()
            let interaction = BasicInteraction()
            let dataSource = BasicDataSource()

            let structure = { (input: ContentInput) in
                NavigationData(router: input.router) {
                    TextData(text: "Title: Sheet A")
                    GroupData(type: .form) {
                        ButtonData(title: "Open Sheet B (V1)", interaction: { input.router.pushScreen(location: .sheetBV1) })
                        ButtonData(title: "Open Sheet B (V2)", interaction: { input.router.pushScreen(location: .sheetBV2) })
                    }
                }
            }
        }
    }
    
    private struct NavigationTestSheetBContainer {
        class Router: SimplifiedRouter<Router.NavigationLocation> {
            enum NavigationLocation: NavigationLocationProtocol, CaseIterable {
                case sheetC
                
                @ViewBuilder
                func toView() -> some View {
                    NavigationTestSheetCContainer.Content().buildView()
                }
            }
        }
        struct Content: ContentProtocol {
            let router = Router()
            let interaction = BasicInteraction()
            let dataSource = BasicDataSource()

            let structure = { (input: ContentInput) in
                NavigationData(router: input.router) {
                    TextData(text: "Title: Sheet B (V1)")
                    GroupData(type: .form) {
                        ButtonData(title: "Open Sheet C", interaction: { input.router.pushScreen(location: .sheetC) })
                    }
                }
            }
        }
    }
    
    private struct NavigationTestSheetCContainer {
        class Router: SimplifiedRouter<Router.NavigationLocation> {
            enum NavigationLocation: NavigationLocationProtocol, CaseIterable {
                case sheetDV1
                case sheetDV2
                
                @ViewBuilder
                func toView() -> some View {
                    switch self {
                    case .sheetDV1: Text("Title: Sheet D (V1)")
                    case .sheetDV2: Text("title: Sheet D (V2)")
                    }
                }
            }
        }
        struct Content: ContentProtocol {
            let router = Router()
            let interaction = BasicInteraction()
            let dataSource = BasicDataSource()

            let structure = { (input: ContentInput) in
                NavigationData(router: input.router) {
                    TextData(text: "Title: Sheet C")
                    GroupData(type: .form) {
                        ButtonData(title: "Open Sheet D (V1)", interaction: { input.router.pushScreen(location: .sheetDV1) })
                        ButtonData(title: "Open Sheet D (V2)", interaction: { input.router.pushScreen(location: .sheetDV2) })
                    }
                }
            }
        }
    }
}

#endif
