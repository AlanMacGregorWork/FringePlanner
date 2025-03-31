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
        switch ApplicationEnvironment.current {
        case .normal:
            SearchEventContentContainer.createContent(modelContainer: modelContainer)
                .buildView()
        case .testingUI:
            UITestingContentContainer.Content().buildView()
                .onAppear {
                    // Disabling animations for UI tests makes them faster
                    UIView.setAnimationsEnabled(false)
                }
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
