//
//  ContentView.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/10/2024.
//

import SwiftUI

/// Constructs a view from the content
struct ContentView<Content: ContentProtocol>: View {
    @State private var router: Content.RouterType
    // Note: `@State` is required for detecting changes in the data source that trigger a view update
    @State private var dataSource: Content.DataSourceType
    private let container: Content
    
    init(_ container: Content) {
        self._router = .init(initialValue: container.router)
        self.dataSource = container.dataSource
        self.container = container
    }
    
    var body: some View {
        let structure = Content.Structure.init(input: container).structure
        ContentViewGenerator(structure)
    }
}

// MARK: - Helpers

/// Creates a view from a series of `ViewDataProtocol` models
private struct ContentViewGenerator<T>: View {
    let contentViews: T
    
    init<each DataType: ViewDataProtocol>(_ data: repeat each DataType) where T == (repeat (each DataType).ContentView) {
        contentViews = (repeat (each data).createView())
    }
    
    var body: some View {
        TupleView(contentViews)
    }
}

extension ViewDataProtocol {
    /// Helper function to create the view from the type
    @MainActor
    func createView() -> ContentView {
        ContentView(data: self)
    }
}

extension ContentProtocol {
    /// Helper to construct the view from the protocol
    @MainActor
    func buildView() -> ContentView<Self> {
        .init(self)
    }
}
