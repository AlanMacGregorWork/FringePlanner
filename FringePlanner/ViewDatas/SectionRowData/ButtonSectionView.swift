//
//  ButtonSectionView.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/12/2024.
//

import SwiftUI

/// Displays a button with a title and right pointing arrow
struct ButtonSectionView<Content: View>: View {
    let closure: (() -> Void)
    @ViewBuilder let content: (() -> Content)
    
    var body: some View {
        Button(
            action: closure,
            // `NavigationLink` requires a `View` destination otherwise its contents will appear disabled. Including
            // it as the `label` of `Button` allows the UI to be rendered correctly even though the `closure` does
            // not trigger a view.
            label: {
                NavigationLink(destination: { Text("") }, label: content)
            }
        )
        // Removes the default button tint which may appear blue in light mode
        .tint(.primary)
    }
}

extension ButtonSectionView {
    /// Helper initializer for simple text-only buttons
    init(title: String, closure: @escaping () -> Void) where Content == Text {
        self.init(closure: closure, content: { Text(title) })
    }
}

// MARK: - Previews

#Preview(traits: .fixedLayout(width: 400, height: 100)) {
    Form {
        Section {
            ButtonSectionView(title: "Sample Button", closure: {})
        }
    }
}
