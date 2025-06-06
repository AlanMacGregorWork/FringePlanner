//
//  ExampleTest.swift
//  FringePlannerTests
//
//  Created by Alan MacGregor on 16/09/2024.
//

import Testing
import SwiftUI
import SwiftData
@testable import FringePlanner

@Suite("Example Tests")
struct ExampleTest {

    private let content: Content
    
    init() async throws {
        let modelContainer = try ModelContainer()
        let constructionHelper = ConstructionHelper(modelContainer: modelContainer)
        let dataSource = DataSource()
        let interaction = Interaction(dataSource: dataSource)
        let router = Router(constructionHelper: constructionHelper)
        self.content = Content(router: router, interaction: interaction, dataSource: dataSource)
    }
    
    @MainActor
    @Test("Interacting should update the data source")
    func testExample() async throws {
        // Initial row
        content.expect {
            NavigationData {
                DebugTextData(text: "Row Value: 0")
                ButtonData(title: "Add To Value", interaction: { content.interaction.addToButtonPress() })
            }
        }
        
        // User taps the button
        content.interaction.addToButtonPress()
        
        // Row value should increase to 1
        content.expect {
            NavigationData {
                DebugTextData(text: "Row Value: 1")
                ButtonData(title: "Add To Value", interaction: { content.interaction.addToButtonPress() })
            }
        }
    }
}

// MARK: - Supporting Models

private typealias Router = SimplifiedRouter<BasicNavigationLocation>

private class DataSource: DataSourceProtocol {
    @Published var buttonPresses = 0
}

private struct Interaction: InteractionProtocol {
    let dataSource: DataSource
    
    func addToButtonPress() {
        dataSource.buttonPresses += 1
    }
}

private struct Content: ContentProtocol {
    let router: Router
    let interaction: Interaction
    let dataSource: DataSource
    
    struct Structure: StructureProtocol {
        let input: Content

        var structure: some ViewDataProtocol {
            NavigationData {
                DebugTextData(text: "Row Value: \(input.dataSource.buttonPresses)")
                ButtonData(title: "Add To Value", interaction: input.interaction.addToButtonPress)
            }
        }
    }
}
