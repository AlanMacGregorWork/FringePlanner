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
            MainView()
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
