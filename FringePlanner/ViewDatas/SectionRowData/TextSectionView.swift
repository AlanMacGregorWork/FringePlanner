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
    let text: AttributedString.StringProvider
    /// Stores the converted AttributedString from HTML when needed
    @State private var attributedContent: AttributedString?

    var body: some View {
        Group {
            if let title {
                LabeledContent(title) {
                    textView
                }
            } else {
                textView
            }
        }
        .task {
            // Trigger async HTML conversion when view appears
            await loadAttributedContent()
        }
    }

    /// Provides the appropriate text view based on content type
    @ViewBuilder
    private var textView: some View {
        switch text {
        case .attributedString(let attributedString):
            // Direct rendering for already-attributed content
            Text(attributedString)
        case .htmlString:
            if let attributedContent {
                // Show converted HTML content when available
                Text(attributedContent)
            } else {
                // Show loading indicator while HTML is being processed
                ProgressView()
            }
        }
    }
    
    /// Converts HTML string to AttributedString asynchronously on the main actor
    @MainActor
    private func loadAttributedContent() async {
        switch text {
        case .attributedString:
            // No conversion needed for already-attributed content
            break
        case .htmlString(let htmlString):
            guard attributedContent == nil else { return }
            // Convert HTML to AttributedString with fallback to plain text if conversion fails
            attributedContent = AttributedString(fromHTML: htmlString) ?? AttributedString(htmlString)
        }
    }
}

extension TextSectionView {
    init(title: String?, text: String) {
        self.title = title
        self.text = .attributedString(AttributedString(text))
    }
    /// Note: If the title is included, the `text` will not include custom formatting
    init(title: String?, html: String) {
        self.title = title
        self.text = .htmlString(html)
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
