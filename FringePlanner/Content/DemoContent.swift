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
    
    typealias Router = SimplifiedRouter<NavigationLocation>

    struct Content<DataSourceType: DemoDataSource>: ContentProtocol {
        let router: Router
        let interaction: Interaction<DataSourceType>
        let dataSource: DataSourceType
        typealias Structure = DemoContentContainer.Structure<DataSourceType>
    }
    
    // MARK: - Structure
    
    struct Structure<DataSourceType: DemoDataSource>: StructureProtocol {
        let input: Content<DataSourceType>
        
        var structure: some ViewDataProtocol {
            NavigationData {
                DebugTextData(text: "General Row: \(input.dataSource.section2Row1Number)")
                GroupData(type: .form) {
                    GroupData(type: .section) {
                        DebugTextData(text: input.dataSource.title)
                    }
                    DebugButtonData(title: "Value updated from row 2: \(input.dataSource.section1Row1Number)", interaction: { print("Test") })
                    DebugButtonData(title: "Update row 1", interaction: {input.interaction.updateSection1Row1() })
                    
                    ForEachData(data: DemoContentContainer.Router.NavigationLocation.allCases) { sheet in
                        DebugButtonData(title: "Push \(sheet.title)", interaction: input.interaction.pushSheet(sheet))
                    }
                    
                    GroupData(type: .section) {
                        DebugButtonData(title: "Add Row", interaction: { input.interaction.addRow() })
                        ForEachData(data: input.dataSource.uuids) { uuid in
                            DebugTextData(text: "ID: \(uuid.uuidString.prefix(10))")
                        }
                    }
                    
                    GroupData(type: .section) {
                        DebugButtonData(title: "Add 1 to values: \(input.dataSource.section2Row1Number)", interaction: { input.interaction.updateSection2Row1() })
                        DebugTextData(text: "General Row: \(input.dataSource.section2Row1Number)")
                        CustomTimeData(timerOn: input.dataSource.timerOn, interaction: { input.interaction.toggleTimer() })
                    }
                }
            }
        }
    }
     
    // MARK: - Create
    
    static func createDemoContent(constructionHelper: ConstructionHelper) -> Content<OverridingDataSource> {
        let router = Router(constructionHelper: constructionHelper)
        let dataSource = OverridingDataSource()
        let interaction = Interaction(router: router, dataSource: dataSource)
        return Content(router: router, interaction: interaction, dataSource: dataSource)
    }

    // MARK: Protocols

    protocol DemoDataSource: DataSourceProtocol {
        var section1Row1Number: Int { get set }
        var section2Row1Number: Int { get set }
        var uuids: [UUID] { get set }
        var timerOn: Bool { get set }
        var title: String { get }
    }
    
    // MARK: Models
    
    struct Interaction<DataSourceType: DemoDataSource>: InteractionProtocol {
        private let router: Router
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
        func pushSheet(_ sheet: NavigationLocation) -> (() -> Void) {
            { [weak router] in
                router?.pushSheet(location: sheet)
            }
        }
        func addRow() {
            dataSource.uuids.append(.init())
        }
    }
    
    enum NavigationLocation: NavigationLocationProtocol, CaseIterable {
        case sheet1
        case sheet2
        
        @ViewBuilder
        func toView(constructionHelper: ConstructionHelper) -> some View {
            Text(title)
        }
        
        var title: String {
            switch self {
            case .sheet1: "Sheet 1"
            case .sheet2: "Sheet 2"
            }
        }
    }
    
    @Observable
    class DataSource: DemoDataSource {
        var uuids: [UUID] = []
        var section1Row1Number = 0
        var section2Row1Number = 0
        var timerOn = false
        let title: String = "Using DataSource"
    }
    
    @Observable
    class OverridingDataSource: DemoDataSource {
        var uuids: [UUID] = []
        var section1Row1Number = 0
        var section2Row1Number = 0
        var timerOn = false
        let title: String = "Using Override"
    }
}

#endif
