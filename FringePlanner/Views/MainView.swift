//
//  MainView.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/03/2025.
//

import SwiftUI
import SwiftData

/// The main view of the application that handles the loading of the container and the display of the content
struct MainView: View {
    private let status = ContainerLoadedStatus.current
    
    var body: some View {
        switch status {
        case .successfullyLoaded(let modelContainer): Self.bodyWith(modelContainer: modelContainer)
        case .failed: Text("Failed to setup container")
        }
    }
    
    @ViewBuilder
    static func bodyWith(modelContainer: ModelContainer) -> some View {
        let constructionHelper = ConstructionHelper(modelContainer: modelContainer)
        switch ApplicationEnvironment.current {
        case .normal:
            TabView {
                SearchEventContentContainer.createContent(constructionHelper: constructionHelper)
                    .buildView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                
                PlannerContentContainer.createContent(constructionHelper: constructionHelper)
                    .buildView()
                    .tabItem {
                        Label("Planner", systemImage: "checkmark.rectangle.stack")
                    }
            }
            .modelContainer(modelContainer)
        case .testingUI:
            UITestingContentContainer.Content(constructionHelper: constructionHelper).buildView()
                .onAppear {
                    // Disabling animations for UI tests makes them faster
                    UIView.setAnimationsEnabled(false)
                }
                .modelContainer(modelContainer)
        case .preview:
            Text("Preview")
        case .testingUnit:
            Text("Unit Testing")
        }
    }
}

// MARK: -

/// Handles the success and failure of generating the SwiftData container
private enum ContainerLoadedStatus {
    case successfullyLoaded(ModelContainer)
    case failed
    
    static var current: Self {
        return (try? ModelContainer.create()).map({ .successfullyLoaded($0) }) ?? .failed
    }
}
