//
//  ContentView.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 10/10/2024.
//

import SwiftUI

/// Constructs a view from the content
struct ContentView<Content: ContentProtocol>: View {
    @ObservedObject private var router: Content.RouterType
    @ObservedObject private var dataSource: Content.DataSourceType
    @ObservedObject private var interaction: Content.InteractionType
    private let container: Content
    
    init(_ container: Content) {
        self._router = .init(initialValue: container.router)
        self._dataSource = .init(initialValue: container.dataSource)
        self._interaction = .init(initialValue: container.interaction)
        self.container = container
    }
    
    var body: some View {
        let content = container.structure(.init(router: router, dataSource: dataSource, interaction: interaction, reference: container))
        ContentViewGenerator(content)
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
    func createView() -> ContentView {
        ContentView(data: self)
    }
}

extension ContentProtocol {
    /// Helper to construct the view from the protocol
    func buildView() -> ContentView<Self> {
        .init(self)
    }
}
