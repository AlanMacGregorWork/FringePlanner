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
    
    struct Interaction: InteractionProtocol {
        let router: Router
        
        func push(sheet: Router.NavigationLocation) {
            self.router.pushSheet(location: sheet)
        }
    }
    
    enum NavigationLocation: NavigationLocationProtocol {
        case navigationTests
        case renderingTests
        
        @ViewBuilder
        func toView(constructionHelper: ConstructionHelper) -> some View {
            switch self {
            case .navigationTests: NavigationTestSheetAContainer.Content(constructionHelper: constructionHelper).buildView()
            case .renderingTests: RenderingTestsContainer.Content(constructionHelper: constructionHelper).buildView()
            }
        }
    }
    
    struct Content: ContentProtocol {
        let router: Router
        let interaction: Interaction
        let dataSource = BasicDataSource()
        typealias Structure = UITestingContentContainer.Structure
        
        init(constructionHelper: ConstructionHelper) {
            let router = Router(constructionHelper: constructionHelper)
            let interaction = Interaction(router: router)
            self.interaction = interaction
            self.router = router
        }
    }
    
    struct Structure: StructureProtocol {
        let input: Content
        
        var structure: some ViewDataProtocol {
            NavigationData(router: input.router) {
                DebugTextData(text: "Title: Main Sheet")
                GroupData(type: .form) {
                    GroupData(type: .section) {
                        DebugButtonData(title: "Navigation Tests", interaction: { input.interaction.push(sheet: .navigationTests) })
                        DebugButtonData(title: "Rendering Tests", interaction: { input.interaction.push(sheet: .renderingTests) })
                    }
                }
            }
        }
    }
}

// MARK: - NavigationTestSheetAContainer

private struct NavigationTestSheetAContainer {
    typealias Router = SimplifiedRouter<NavigationLocation>
    
    enum NavigationLocation: NavigationLocationProtocol {
        case sheetBV1(parentRouter: Router)
        case sheetBV2
        
        @ViewBuilder
        func toView(constructionHelper: ConstructionHelper) -> some View {
            switch self {
            case .sheetBV1(let parentRouter):
                NavigationTestSheetBContainer.Content(parentRouter: parentRouter, constructionHelper: constructionHelper).buildView()
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
        let router: Router
        let interaction = BasicInteraction()
        let dataSource = BasicDataSource()
        typealias Structure = NavigationTestSheetAContainer.Structure

        init(constructionHelper: ConstructionHelper) {
            let router = Router(constructionHelper: constructionHelper)
            self.router = router
        }
    }
    
    struct Structure: StructureProtocol {
        let input: Content
        
        var structure: some ViewDataProtocol {
            NavigationData(router: input.router) {
                DebugTextData(text: "Title: Sheet A")
                GroupData(type: .form) {
                    DebugButtonData(title: "Open Sheet B (V1)", interaction: { input.router.pushSheet(location: .sheetBV1(parentRouter: input.router)) })
                    DebugButtonData(title: "Open Sheet B (V2)", interaction: { input.router.pushSheet(location: .sheetBV2) })
                }
            }
        }
    }
}

// MARK: - NavigationTestSheetBContainer

private struct NavigationTestSheetBContainer {
    typealias Router = SimplifiedRouter<NavigationLocation>
    
    enum NavigationLocation: NavigationLocationProtocol, CaseIterable {
        case sheetC
        
        @ViewBuilder
        func toView(constructionHelper: ConstructionHelper) -> some View {
            NavigationTestSheetCContainer.Content(constructionHelper: constructionHelper).buildView()
        }
    }
    
    struct Content: ContentProtocol {
        let router: Router
        let interaction = BasicInteraction()
        let dataSource = BasicDataSource()
        let parentRouter: NavigationTestSheetAContainer.Router
        typealias Structure = NavigationTestSheetBContainer.Structure

        init(parentRouter: NavigationTestSheetAContainer.Router, constructionHelper: ConstructionHelper) {
            let router = Router(constructionHelper: constructionHelper)
            self.router = router
            self.parentRouter = parentRouter
        }
    }
    
    struct Structure: StructureProtocol {
        let input: Content

        var structure: some ViewDataProtocol {
            NavigationData(router: input.router) {
                DebugTextData(text: "Title: Sheet B (V1)")
                GroupData(type: .form) {
                    GroupData(type: .section) {
                        DebugButtonData(title: "Open Sheet C", interaction: { input.router.pushSheet(location: .sheetC) })
                    }
                    GroupData(type: .section) {
                        DebugButtonData(title: "Change Parent Selection To Sheet B (V2)", interaction: { input.parentRouter.pushSheet(location: .sheetBV2) })
                    }
                }
            }
        }
    }
}

// MARK: - NavigationTestSheetCContainer

private struct NavigationTestSheetCContainer {
    typealias Router = SimplifiedRouter<NavigationLocation>
    
    enum NavigationLocation: NavigationLocationProtocol, CaseIterable {
        case sheetDV1
        case sheetDV2
        
        @ViewBuilder
        func toView(constructionHelper: ConstructionHelper) -> some View {
            switch self {
            case .sheetDV1: Text("Title: Sheet D (V1)")
            case .sheetDV2: Text("title: Sheet D (V2)")
            }
        }
    }
    
    struct Content: ContentProtocol {
        let router: Router
        let interaction = BasicInteraction()
        let dataSource = BasicDataSource()
        typealias Structure = NavigationTestSheetCContainer.Structure

        init(constructionHelper: ConstructionHelper) {
            let router = Router(constructionHelper: constructionHelper)
            self.router = router
        }
    }
    
    struct Structure: StructureProtocol {
        let input: Content
        
        var structure: some ViewDataProtocol {
            NavigationData(router: input.router) {
                DebugTextData(text: "Title: Sheet C")
                GroupData(type: .form) {
                    DebugButtonData(title: "Open Sheet D (V1)", interaction: { input.router.pushSheet(location: .sheetDV1) })
                    DebugButtonData(title: "Open Sheet D (V2)", interaction: { input.router.pushSheet(location: .sheetDV2) })
                }
            }
        }
    }
}

// MARK: - RenderingTestsContainer

private struct RenderingTestsContainer {
    typealias Router = SimplifiedRouter<BasicNavigationLocation>
    
    @Observable
    class DataSource: DataSourceProtocol {
        var value = 0
    }
    
    struct Interaction: InteractionProtocol {
        let dataSource: DataSource
        
        func addToDataSource() {
            dataSource.value += 1
        }
    }
    
    struct Content: ContentProtocol {
        let router: Router
        let interaction: Interaction
        let dataSource: DataSource
        typealias Structure = RenderingTestsContainer.Structure
        
        init(constructionHelper: ConstructionHelper) {
            let dataSource = DataSource()
            self.router = .init(constructionHelper: constructionHelper)
            self.interaction = .init(dataSource: dataSource)
            self.dataSource = dataSource
        }
    }
    
    struct Structure: StructureProtocol {
        let input: Content

        var structure: some ViewDataProtocol {
            GroupData(type: .form) {
                DebugTextData(text: "Title: Rendering Tests")
                
                GroupData(type: .section) {
                    DebugTextData(text: "Value stored in data model: \(input.dataSource.value)")
                    DebugButtonData(title: "Add 1 to data model directly", interaction: { input.dataSource.value += 1 })
                    DebugButtonData(title: "Add 1 to data model from interaction", interaction: { input.interaction.addToDataSource() })
                }
            }
        }
    }
}
#endif
