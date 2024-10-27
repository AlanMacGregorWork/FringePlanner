//
//  FringePlannerApp.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/09/2024.
//

import SwiftUI

@main
struct FringePlannerApp: App {
    var body: some Scene {
        WindowGroup {
            switch Environment.current {
            case .normal:
                demoView
            case .testingUI:
                UITestingContentContainer.Content().buildView()
                    .onAppear {
                        // Disabling animations for UI tests makes them faster
                        UIView.setAnimationsEnabled(false)
                    }
            case .testingUnit:
                Text("Unit Testing")
            }
        }
    }
    
    /// Defines the different environments the app can use
    private enum Environment {
        case normal
        case testingUnit
        case testingUI
        
        /// Identifies the current environment being used by the app
        static var current: Self {
            if ProcessInfo.processInfo.arguments.contains("ui-test") {
                return .testingUI
            } else if NSClassFromString("XCTestCase") != nil {
                return .testingUnit
            } else {
                return .normal
            }
        }
    }
}

#Preview {
    demoView
}

@ViewBuilder
@MainActor
var demoView: some View {
    DemoContentContainer.createDemoContent()
        .buildView()
}
