//
//  TextSectionView.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/12/2024.
//

import SwiftUI

/// Displays full formatted text without a title, or non-formatted text with a title
/// - Note: String content from the Fringe API often comes in a partial HTML format, so in order for content to
/// appear correctly formatted this should be used to render any string content form the API
struct TextSectionView: View {
    /// Note: If the title is included, the `text` will not include custom formatting
    let title: String?
    let text: AttributedString

    var body: some View {
        if let title {
            LabeledContent(title) {
                Text(text)
            }
        } else {
            Text(text)
        }
    }
}

extension TextSectionView {
    /// Note: If the title is included, the `text` will not include custom formatting
    init(title: String?, text: String) {
        self.title = title
        self.text = AttributedString(from: text) ?? .init(stringLiteral: text)
    }
}

// MARK: - Previews

#Preview(traits: .fixedLayout(width: 400, height: 500)) {
    let formattedText = """
        <b>Some Value</b></br>
        Item here
        Some text. Some text. Some text. Some text. Some text
        """
    let nonFormattedText = """
        Some Value
        Item here
        Some text. Some text. Some text. Some text. Some text
        """
    Form {
        Section("Without Text Formatting") {
            TextSectionView(title: "Some Title", text: nonFormattedText)
            TextSectionView(title: nil, text: nonFormattedText)
        }
        Section("With Text Formatting") {
            TextSectionView(title: "Some Title", text: formattedText)
            TextSectionView(title: nil, text: formattedText)
        }
    }
}
