//
//  Text.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 21/09/2024.
//

import SwiftUI

extension Text {
    /// Font handling for general text use
    enum FringeStyle: CaseIterable {
        case cellBody
        case caption
    }
    
    /// Sets the font & styling to the predefined value
    func fringeStyle(_ style: FringeStyle) -> Text {
        switch style {
        case .cellBody:
            self
                .font(.body)
        case .caption:
            self
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

// Displays a rendered example of all the styles
#Preview(traits: .sizeThatFitsLayout) {
    VStack(alignment: .leading) {
        Grid(alignment: .leading) {
            GridRow {
                Text("Style Name")
                Text("Rendered Style")
            }
            .fontWeight(.bold)
            Divider()
            ForEach(Text.FringeStyle.allCases, id: \.self) { style in
                GridRow {
                    Text("\(style)")
                    Text("Example Text")
                        .fringeStyle(style)
                }
            }
        }
    }
}
