//
//  ButtonSectionView.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/12/2024.
//

import SwiftUI

/// Displays a button with a title and right pointing arrow
struct ButtonSectionView: View {
    let title: String
    let closure: (() -> Void)
    
    var body: some View {
        Button(
            action: closure,
            // `NavigationLink` requires a `View` destination otherwise its contents will appear disabled. Including
            // it as the `label` of `Button` allows the UI to be rendered correctly even though the `closure` does
            // not trigger a view.
            label: { NavigationLink(title, destination: { Text("") }) }
        )
        // Removes the default button tint which may appear blue in light mode
        .tint(.primary)
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
