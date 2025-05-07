//
//  ButtonData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 07/05/2025.
//

import SwiftUI

/// Displays a basic button
struct ButtonData<Content: ViewDataProtocol>: ViewDataProtocol, Equatable {
    @MakeEquatableReadOnly var interaction: (() -> Void)
    @MakeEquatableReadOnly @FringeDataResultBuilder var content: (() -> Content)
    
    struct ContentView: View, ViewProtocol {
        let data: ButtonData
        
        var body: some View {
            Button(action: data.interaction) {
                data.content().createView()
            }
        }
    }
}

// MARK: - Helper Inits

extension ButtonData {
    /// Helper init to produce a general text button
    init(title: String, interaction: @escaping () -> Void) where Content == TextData {
        self = .init(interaction: interaction, content: {
            TextData(text: title)
        })
    }
}
