//
//  GroupData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 11/10/2024.
//

import SwiftUI

/// Allows grouping multiple objects
struct GroupData<Content: ViewDataProtocol>: ViewDataProtocol {
    let type: GroupDataType
    let container: Content
    
    init(type: GroupDataType, @FringeDataResultBuilder _ values: () -> Content) {
        self.type = type
        self.container = values()
    }
    
    struct ContentView: View, ViewProtocol {
        let data: GroupData<Content>
        
        var body: some View {
            switch data.type {
            case .form:
                Form {
                    content
                }
            case .section(let title):
                Section(
                    content: { content },
                    header: { sectionHeader(title: title) }
                )
            }
        }
        
        @ViewBuilder
        /// Creates a section header if the contents are not empty
        private func sectionHeader(title: String?) -> some View {
            if !data.container.isEmpty {
                if let title {
                    Text("\(title)")
                }
            }
        }
        
        private var content: some View {
            data.container.createView()
        }
    }
}

// MARK: - Enums

/// The visual representation to use for the grouping
enum GroupDataType: Equatable {
    case form
    case section(title: String? = nil)
    
    /// A section with no title 
    static var section: Self { Self.section(title: nil) }
}
