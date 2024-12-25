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
    
    #warning("Update deprecations")
    @available(*, deprecated, message: "ContainerData should be instantiated")
    init<each ParameterContent: ViewDataProtocol>(
        type: GroupDataType,
        @FringeDataResultBuilder _ data: () -> (repeat each ParameterContent)
    ) where Content == ContainerData<repeat each ParameterContent> {
        self.type = type
        self.container = ContainerData(values: data)
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
            if !contentsIsEmpty {
                if let title {
                    Text("\(title)")
                }
            }
        }
        
        private var content: some View {
            data.container.createView()
        }
        
        /// Checks if all the contents are empty (Used to determine if the content should be shown)
        private var contentsIsEmpty: Bool {
            guard let isEmptyType = data.container as? ViewDataIsEmpty else { return false }
            guard isEmptyType.isEmpty else { return false }
            return true
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
