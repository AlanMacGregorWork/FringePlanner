//
//  MainScreen.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 16/09/2024.
//

import SwiftUI

struct MainScreen: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Fringe Planner")
        }
        .padding()
    }
}

#Preview {
    MainScreen()
}
