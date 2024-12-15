//
//  LinkSectionView.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/12/2024.
//

import SwiftUI

/// Displays a link with a title and link name
struct LinkSectionView: View {
    let title: String
    let linkName: String
    let link: URL?
    
    init(title: String, linkName: String, link: String) {
        self.title = title
        self.linkName = linkName
        self.link = URL(string: link)
        fringeAssert(self.link != nil, "Link failed to be converted to URL: \(link)")
    }
    
    var body: some View {
        if link != nil {
            LabeledContent(title) {
                Button(action: openLink) {
                    Text(linkName)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                }
            }
        }
    }
    
    private func openLink() {
        guard let link else { return }
        UIApplication.shared.open(link) { success in
            fringeAssert(success, "URL failed to open")
        }
    }
}

// MARK: - Previews

#Preview(traits: .fixedLayout(width: 400, height: 500)) {
    Form {
        Section("With Valid URL") {
            LinkSectionView(title: "Link Title", linkName: "Link Name", link: "http://www.google.com")
        }
        Section("With Invalid URL (Presents Empty View)") {
            LinkSectionView(title: "Link Title", linkName: "Link Name", link: "")
        }
        Section("With Longer Title") {
            LinkSectionView(title: "Some Much Longer Title", linkName: "Some Different Link", link: "http://www.google.com")
        }
        Section("With Longer Link Name") {
            LinkSectionView(title: "Some Differen Title", linkName: "Some Much Longer Link", link: "http://www.google.com")
        }
    }
}
