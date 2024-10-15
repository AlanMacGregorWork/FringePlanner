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
                    
                    ForEachData(data: RouterType.NavigationLocation.allCases) { screen in
                        ButtonData(title: "Push \(screen.title)", interaction: input.interaction.pushScreen(screen))
                    }
                    
                    GroupData(type: .section) {
                        ButtonData(title: "Add Row", interaction: input.interaction.addRow)
                        ForEachData(data: input.dataSource.uuids) { uuid in
                            TextData(text: "ID: \(uuid.uuidString.prefix(10))")
                        }
                    }
                    
                    GroupData(type: .section) {
                        ButtonData(title: "Add 1 to values: \(input.dataSource.section2Row1Number)", interaction: input.interaction.updateSection2Row1)
                        TextData(text: "General Row: \(input.dataSource.section2Row1Number)")
                        CustomTimeData(timerOn: input.dataSource.timerOn, interaction: input.interaction.toggleTimer)
                    }
                }
            }
        }
    }
    
    static func createDemoContent() -> Content<Router, Interaction<Router, OverridingDataSource>, OverridingDataSource> {
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
        func pushScreen(_ screen: NavigationLocation) -> (() -> Void)
        func addRow()
    }

    protocol DemoDataSource: DataSourceProtocol {
        var section1Row1Number: Int { get set }
        var section2Row1Number: Int { get set }
        var uuids: [UUID] { get set }
        var timerOn: Bool { get set }
        var title: String { get }
    }

    protocol DemoRouter: RouterProtocol where NavigationLocation == DemoContentContainer.NavigationLocation {}
    
    // MARK: Models
    
    class Interaction<RouterType: DemoRouter, DataSourceType: DemoDataSource>: BaseInteraction, DemoInteraction {
        @Published var router: RouterType
        private let dataSource: DataSourceType
        
        init(router: RouterType, dataSource: DataSourceType) {
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
        func pushScreen(_ screen: RouterType.NavigationLocation) -> (() -> Void) {
            { [weak router] in
                router?.pushScreen(location: screen)
            }
        }
        func addRow() {
            dataSource.uuids.append(.init())
        }
    }
    
    class Router: SimplifiedRouter<NavigationLocation>, DemoRouter {}
    
    enum NavigationLocation: NavigationLocationProtocol, CaseIterable {
        case screen1
        case screen2
        
        @ViewBuilder
        func toView() -> some View {
            Text(title)
        }
        
        var title: String {
            switch self {
            case .screen1: "Screen 1"
            case .screen2: "Screen 2"
            }
        }
    }
    
    class DataSource: ObservableObject, DemoDataSource {
        @Published var uuids: [UUID] = []
        @Published var section1Row1Number = 0
        @Published var section2Row1Number = 0
        @Published var timerOn = false
        let title: String = "Using DataSource"
    }
    
    class OverridingDataSource: ObservableObject, DemoDataSource {
        @Published var uuids: [UUID] = []
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
