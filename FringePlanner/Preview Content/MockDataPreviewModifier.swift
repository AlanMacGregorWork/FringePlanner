//
//  MockDataPreviewModifier.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 26/04/2025.
//

import SwiftData
import SwiftUI

/// Sets up mock data for use in a preview
struct MockDataPreviewModifier: PreviewModifier {
    private let config: [Int: SeededContent.EventSeedConfig]
    
    init(config: [Int: SeededContent.EventSeedConfig] = [:]) {
        self.config = config
    }
    
    static func makeSharedContext() async throws -> ModelContainer {
        try ModelContainer.create()
    }

    func body(content: Content, context: ModelContainer) -> some View {
        AsyncView(asyncOperation: {
            // Add mock events to the container
            let apiEvents = SeededContent(seed: 123).events(for: config)
            let actor = ImportAPIActor(modelContainer: context)
            try await actor.updateEvents(apiEvents)
        }, contentView: { _ in
            // Return the UI with the container
            content
                .modelContainer(context)
        })
    }
}
