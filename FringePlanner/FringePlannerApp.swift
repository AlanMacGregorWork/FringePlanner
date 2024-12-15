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
}

#Preview {
    demoView
}

@ViewBuilder
@MainActor
var demoView: some View {
    SearchEventContentContainer.createContent()
        .buildView()
}
