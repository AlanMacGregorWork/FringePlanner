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
            demoView
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
        do {
            let config = ModelConfiguration()
            let container = try ModelContainer(for: DBFringeEvent.self, DBFringeVenue.self, DBFringePerformance.self, configurations: config)
            return .successfullyLoaded(container)
        } catch {
            fringeAssertFailure("Failed to setup container")
            return .failed
        }
    }
}
