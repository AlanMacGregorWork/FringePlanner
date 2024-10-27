//
//  ExampleTest.swift
//  FringePlannerTests
//
//  Created by Alan MacGregor on 16/09/2024.
//

import Testing
import SwiftUI
@testable import FringePlanner

@Suite("Example Tests")
struct ExampleTest {
    
    private let content: Content
    
    init() {
        let dataSource = DataSource()
        let interaction = Interaction(dataSource: dataSource)
        let router = Router()
        self.content = Content(router: router, interaction: interaction, dataSource: dataSource)
    }
    
    @Test("Interacting should update the data source")
    func testExample() async throws {
        // Initial row
        content.expect {
            NavigationData(router: content.router) {
                TextData(text: "Row Value: 0")
                ButtonData(title: "Add To Value", interaction: content.interaction.addToButtonPress)
            }
        }
        
        // User taps the button
        content.interaction.addToButtonPress()
        
        // Row value should increase to 1
        content.expect {
            NavigationData(router: content.router) {
                TextData(text: "Row Value: 1")
                ButtonData(title: "Add To Value", interaction: content.interaction.addToButtonPress)
            }
        }
    }
}

// MARK: - Supporting Models

fileprivate typealias Router = SimplifiedRouter<BasicNavigationLocation>

fileprivate class DataSource: DataSourceProtocol {
    @Published var buttonPresses = 0
}

fileprivate class Interaction: BaseInteraction, InteractionProtocol {
    let dataSource: DataSource
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    func addToButtonPress() {
        dataSource.buttonPresses += 1
    }
}

fileprivate struct Content: ContentProtocol {
    let router: Router
    let interaction: Interaction
    let dataSource: DataSource
    
    let structure = { (input: ContentInput) in
        NavigationData(router: input.router) {
            TextData(text: "Row Value: \(input.dataSource.buttonPresses)")
            ButtonData(title: "Add To Value", interaction: input.interaction.addToButtonPress)
        }
    }
}
