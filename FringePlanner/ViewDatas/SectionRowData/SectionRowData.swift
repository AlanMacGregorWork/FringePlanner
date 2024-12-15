//
//  SectionRowData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 15/12/2024.
//

import SwiftUI

/// Displays basic content that can be used in a section
struct SectionRowData: ViewDataProtocol, Equatable {
    let value: ValueType
    
    struct ContentView: View, ViewProtocol {
        let data: SectionRowData
        
        var body: some View {
            switch data.value {
            case .text(let title, let text):
                TextSectionView(title: title, text: text)
            case .url(let title, let value, let url):
                LinkSectionView(title: title, linkName: value, link: url)
            case .button(let title, let closure):
                ButtonSectionView(title: title, closure: closure.wrappedValue)
            }
        }
    }
    
    /// The content to be used for the row
    enum ValueType: Equatable {
        case url(title: String, value: String, url: String)
        case text(title: String?, text: String)
        case button(title: String, closure: MakeEquatableReadOnly<(() -> Void)>)
    }
}

// MARK: - Helper Inits

extension SectionRowData {
    init(title: String? = nil, text: String) {
        self.value = .text(title: title, text: text)
    }
    
    init(title: String, value: URL) {
        self.value = .url(title: title, value: value.absoluteString, url: value.absoluteString)
    }
    
    init(title: String, phoneNumber: String) {
        self.value = .url(title: title, value: phoneNumber, url: "tel:\(phoneNumber)")
    }
    
    init(title: String, email: String) {
        self.value = .url(title: title, value: email, url: "mailto:\(email)")
    }
}

// MARK: - Previews

#Preview(traits: .fixedLayout(width: 400, height: 500)) {
    GroupData(type: .form) {
        GroupData(type: .section(title: "Text With Title")) {
            SectionRowData(title: "Some Title", text: "Some Text")
        }
        GroupData(type: .section(title: "Text Without Title")) {
            SectionRowData(title: nil, text: "Some Text")
        }
        
        if let url = URL(string: "https://www.google.com") {
            GroupData(type: .section(title: "Text URL")) {
                SectionRowData(title: "Some URL", value: url)
            }
        } else {
            GroupData(type: .section(title: "Failed to generate URL")) {
                SectionRowData(text: "Failed")
            }
        }
        
        GroupData(type: .section(title: "Phone Number")) {
            SectionRowData(title: "Main Number", phoneNumber: "09992 343345")
        }
        
        GroupData(type: .section(title: "Email")) {
            SectionRowData(title: "Some Email", email: "fake-email@test.com")
        }
    }.createView()
}
