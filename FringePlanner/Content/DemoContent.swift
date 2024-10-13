//
//  DemoContent.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/10/2024.
//

import SwiftUI

// Note: Content to be used for debug purposes

#if DEBUG

struct DemoContentContainer {

    struct Content<RouterType: DemoRouter, InteractionType: DemoInteraction, DataSourceType: DemoDataSource>: ContentProtocol {
        let router: RouterType
        let interaction: InteractionType
        let dataSource: DataSourceType
        
        let structure = { (input: ContentInput) in
            NavigationData(router: input.router) {
                TextData(text: "General Row: \(input.dataSource.section2Row1Number)")
                GroupData(type: .form) {
                    GroupData(type: .section) {
                        TextData(text: input.dataSource.title)
                    }
                    ButtonData(title: "Value updated from row 2: \(input.dataSource.section1Row1Number)", interaction: { print("Test") })
                    ButtonData(title: "Update row 1", interaction: input.interaction.updateSection1Row1)
                    ButtonData(title: "Push Screen 1", interaction: input.interaction.pushScreen1)
                    ButtonData(title: "Push Screen 2", interaction: input.interaction.pushScreen2)
                    
                    GroupData(type: .section) {
                        ButtonData(title: "Add 1 to values: \(input.dataSource.section2Row1Number)", interaction: input.interaction.updateSection2Row1)
                        TextData(text: "General Row: \(input.dataSource.section2Row1Number)")
                        CustomTimeData(timerOn: input.dataSource.timerOn, interaction: input.interaction.toggleTimer)
                    }
                }
            }
        }
    }
    
    static func createDemoContent() -> Content<Router, Interaction<OverridingDataSource>, OverridingDataSource> {
        let router = Router()
        let dataSource = OverridingDataSource()
        let interaction = Interaction(router: router, dataSource: dataSource)
        return Content(router: router, interaction: interaction, dataSource: dataSource)
    }

    // MARK: Protocols

    protocol DemoInteraction: InteractionProtocol {
        func updateSection1Row1()
        func updateSection2Row1()
        func toggleTimer()
        func pushScreen1()
        func pushScreen2()
    }

    protocol DemoDataSource: DataSourceProtocol {
        var section1Row1Number: Int { get set }
        var section2Row1Number: Int { get set }
        var timerOn: Bool { get set }
        var title: String { get }
    }

    protocol DemoRouter: RouterProtocol {}
    
    // MARK: Models
    
    class Interaction<DataSourceType: DemoDataSource>: ObservableObject, DemoInteraction {
        @Published var router: Router
        private let dataSource: DataSourceType
        
        init(router: Router, dataSource: DataSourceType) {
            self.router = router
            self.dataSource = dataSource
        }
        
        func updateSection1Row1() {
            dataSource.section1Row1Number += 1
        }
        func updateSection2Row1() {
            dataSource.section2Row1Number += 1
        }
        func toggleTimer() {
            dataSource.timerOn.toggle()
        }
        func pushScreen1() {
            router.pushScreen(location: .screen1)
        }
        func pushScreen2() {
            router.pushScreen(location: .screen2)
        }
    }
    
    class Router: ObservableObject, DemoRouter {
        @Published var pushedSheet: NavigationLocation?
        
        enum NavigationLocation: NavigationLocationProtocol {
            case screen1
            case screen2
            
            @ViewBuilder
            func toView() -> some View {
                switch self {
                case .screen1: Text("Screen 1")
                case .screen2: Text("Screen 2")
                }
            }
        }
        
        func pushScreen(location: NavigationLocation) {
            pushedSheet = location
        }
    }
    
    class DataSource: ObservableObject, DemoDataSource {
        @Published var section1Row1Number = 0
        @Published var section2Row1Number = 0
        @Published var timerOn = false
        let title: String = "Using DataSource"
    }
    
    class OverridingDataSource: ObservableObject, DemoDataSource {
        @Published var section1Row1Number = 0
        @Published var section2Row1Number = 0
        @Published var timerOn = false
        let title: String = "Using Override"
    }
}

struct DemoContentPage2<RouterType: RouterProtocol, InteractionType: InteractionProtocol, DataSourceType: DataSourceProtocol>: ContentProtocol {
    let router: RouterType
    let interaction: InteractionType
    let dataSource: DataSourceType
    
    let structure = { (_: ContentInput) in
        TextData(text: "Temp Page #2")
    }
}

#endif
