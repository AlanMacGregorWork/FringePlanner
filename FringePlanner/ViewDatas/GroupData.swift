//
//  GroupData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 11/10/2024.
//

import SwiftUI

/// Allows grouping multiple objects
struct GroupData<each Content: ViewDataProtocol>: ViewDataProtocol {
    typealias ContentView = GroupView<repeat each Content>
    let type: GroupDataType
    let values: (repeat each Content)
    
    init(
        type: GroupDataType,
        @FringeDataResultBuilder _ data: () -> (repeat each Content)
    ) {
        self.type = type
        self.values = data()
    }
    
    struct GroupView<each T: ViewDataProtocol>: View, ViewProtocol {
        let data: GroupData<repeat each T>
        
        var body: some View {
            switch data.type {
            case .form:
                Form {
                    content
                }
            case .section:
                Section {
                    content
                }
            }
        }
        
        private var content: some View {
            TupleView((repeat (each data.values).createView()))
        }
    }
}

// MARK: - Enums

/// The visual representation to use for the grouping
enum GroupDataType {
    case form
    case section
}
