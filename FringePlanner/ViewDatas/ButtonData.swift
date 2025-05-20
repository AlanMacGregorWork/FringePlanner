//
//  ButtonData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 07/05/2025.
//

import SwiftUI

/// Displays a basic button
struct ButtonData<Content: ViewDataProtocol>: ViewDataProtocol {
    @MakeEquatableReadOnly var interaction: (() -> Void)
    let includeNavigationFlair: Bool
    let content: Content
    
    init(interaction: @escaping () -> Void, includeNavigationFlair: Bool = false, @FringeDataResultBuilder content: () -> Content) {
        self._interaction = .init(wrappedValue: interaction)
        self.content = content()
        self.includeNavigationFlair = includeNavigationFlair
    }
    
    struct ContentView: View, ViewProtocol {
        let data: ButtonData
        
        var body: some View {
            if data.includeNavigationFlair {
                ButtonWithNavigationIndicator(closure: data.interaction) {
                    buttonContent
                }
            } else {
                Button(action: data.interaction) {
                    buttonContent
                }
            }
        }
        
        private var buttonContent: some View {
            data.content.createView()
        }
    }
}

// MARK: - Helper Inits

extension ButtonData {
    /// Helper init to produce a general text button
    init(title: String, interaction: @escaping () -> Void) where Content == TextData {
        self = .init(interaction: interaction, content: {
            TextData(title)
        })
    }
}

// MARK: - Preview

#Preview("Basic title init") {
    ButtonData(
        title: "Some title", 
        interaction: {
            print("Tapped")
        })
    .createView()
}

#Preview("Custom data") {
    ButtonData(
        interaction: {
            print("Tapped")
        },
        content: {
            TextData("Alternative title")
        })
    .createView()
}

#Preview("Custom data (with flair)") {
    ButtonData(
        interaction: {
            print("Tapped")
        },
        includeNavigationFlair: true,
        content: {
            TextData("Alternative title")
        })
    .createView()
}
