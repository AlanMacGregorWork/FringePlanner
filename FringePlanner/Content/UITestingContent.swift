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
    typealias Router = SimplifiedRouter<NavigationLocation>
    
    class Interaction: BaseInteraction, InteractionProtocol {
        let router: Router
        
        init(router: Router) {
            self.router = router
        }
        
        func push(sheet: Router.NavigationLocation) {
            self.router.pushSheet(location: sheet)
        }
        
        func pushNavigationTestsSheet() {
            self.router.pushSheet(location: .navigationTests)
        }
    }
    
    enum NavigationLocation: NavigationLocationProtocol {
        case navigationTests
        
        @ViewBuilder
        func toView() -> some View {
            NavigationTestSheetAContainer.Content().buildView()
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
        typealias Router = SimplifiedRouter<NavigationLocation>
        
        enum NavigationLocation: NavigationLocationProtocol {
            case sheetBV1(parentRouter: Router)
            case sheetBV2
            
            @ViewBuilder
            func toView() -> some View {
                switch self {
                case .sheetBV1(let parentRouter):
                    NavigationTestSheetBContainer.Content(parentRouter: parentRouter).buildView()
                case .sheetBV2:
                    Text("Title: Sheet B (V2)")
                }
            }
            
            static func == (lhs: Self, rhs: Self) -> Bool {
                // Due to equating a `NavigationLocation` with an associated value to a router, it is necessary
                // to override the `Equatable` check
                func getId(for caseValue: Self) -> Int {
                    switch caseValue {
                    case .sheetBV1: return 1
                    case .sheetBV2: return 2
                    }
                }
                return getId(for: lhs) == getId(for: rhs)
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
                        ButtonData(title: "Open Sheet B (V1)", interaction: { input.router.pushSheet(location: .sheetBV1(parentRouter: input.router)) })
                        ButtonData(title: "Open Sheet B (V2)", interaction: { input.router.pushSheet(location: .sheetBV2) })
                    }
                }
            }
        }
    }
    
    private struct NavigationTestSheetBContainer {
        typealias Router = SimplifiedRouter<NavigationLocation>
        
        enum NavigationLocation: NavigationLocationProtocol, CaseIterable {
            case sheetC
            
            @ViewBuilder
            func toView() -> some View {
                NavigationTestSheetCContainer.Content().buildView()
            }
        }
        
        struct Content: ContentProtocol {
            let router = Router()
            let interaction = BasicInteraction()
            let dataSource = BasicDataSource()
            let parentRouter: UITestingContentContainer.NavigationTestSheetAContainer.Router

            let structure = { (input: ContentInput) in
                NavigationData(router: input.router) {
                    TextData(text: "Title: Sheet B (V1)")
                    GroupData(type: .form) {
                        GroupData(type: .section) {
                            ButtonData(title: "Open Sheet C", interaction: { input.router.pushSheet(location: .sheetC) })
                        }
                        GroupData(type: .section) {
                            ButtonData(title: "Change Parent Selection To Sheet B (V2)", interaction: { input.reference.parentRouter.pushSheet(location: .sheetBV2) })
                        }
                    }
                }
            }
        }
    }
    
    private struct NavigationTestSheetCContainer {
        typealias Router = SimplifiedRouter<NavigationLocation>
        
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
        
        struct Content: ContentProtocol {
            let router = Router()
            let interaction = BasicInteraction()
            let dataSource = BasicDataSource()

            let structure = { (input: ContentInput) in
                NavigationData(router: input.router) {
                    TextData(text: "Title: Sheet C")
                    GroupData(type: .form) {
                        ButtonData(title: "Open Sheet D (V1)", interaction: { input.router.pushSheet(location: .sheetDV1) })
                        ButtonData(title: "Open Sheet D (V2)", interaction: { input.router.pushSheet(location: .sheetDV2) })
                    }
                }
            }
        }
    }
}

#endif
