//
//  ViewDataProtocol.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/10/2024.
//

import SwiftUI

/// Defines a type that can contain the data for a view
protocol ViewDataProtocol: Equatable {
    /// The view that can be initialised with the data in this model
    associatedtype ContentView: ViewProtocol where ContentView.DataType == Self
}

/// Defines a view that can be generated from a corresponding data model
@MainActor
protocol ViewProtocol: View {
    /// The data model required to build the view
    associatedtype DataType: ViewDataProtocol
    init(data: DataType)
}
