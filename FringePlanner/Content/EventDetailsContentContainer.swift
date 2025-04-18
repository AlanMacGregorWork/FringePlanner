//
//  EventDetailsContentContainer.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 22/12/2024.
//

import SwiftUI
import SwiftData

/// Container for displaying event
struct EventDetailsContentContainer {
    typealias Router = SimplifiedRouter<BasicNavigationLocation>
}

// MARK: - Content

extension EventDetailsContentContainer {
    struct Content: ContentProtocol {
        typealias Structure = EventDetailsContentContainer.Structure
        let router: Router
        let interaction: Interaction
        let dataSource: DataSource
    }
}

// MARK: - Structure

extension EventDetailsContentContainer {
    struct Structure: StructureProtocol {
        let input: Content
        
        var structure: some ViewDataProtocol {
            let eventCode = input.dataSource.eventCode
            return DatabaseItemsData(
                predicate: #Predicate<DBFringeEvent> { $0.code == eventCode },
                elementView: { event in
                    GroupData(type: .form) {
                        DetailsStructure(event: event)
                        AccessibilityStructure(disabled: event.disabled)
                        DescriptionStructure(event: event)
                    }
                })
        }
    }
}

// MARK: - Data Source

extension EventDetailsContentContainer {
    @Observable
    class DataSource: DataSourceProtocol {
        let eventCode: String
        
        init(eventCode: String) {
            self.eventCode = eventCode
        }
    }
}
    
// MARK: - Interaction
    
extension EventDetailsContentContainer {
    struct Interaction: InteractionProtocol {}
}

// MARK: - Helper

#if DEBUG

extension EventDetailsContentContainer {
    @MainActor
    static func createContent(eventCode: String, constructionHelper: ConstructionHelper) -> Content {
        let router = Router(constructionHelper: constructionHelper)
        let dataSource = DataSource(eventCode: eventCode)
        let interaction = Interaction()
        return Content(router: router, interaction: interaction, dataSource: dataSource)
    }
}

// MARK: - Preview

#Preview {
    AsyncPreviewView(asyncOperation: {
        try await previewModelContainerAndEventCode()
    }, contentView: { modelContainer, eventCode in
        EventDetailsContentContainer.createContent(eventCode: eventCode, constructionHelper: .init(modelContainer: modelContainer)).buildView()
            .modelContainer(modelContainer)
    })
}

private func previewModelContainerAndEventCode() async throws -> (ModelContainer, String) {
    let modelContainer = try ModelContainer.create()
    let apiEvents = SeededContent(seed: 123).events()
    let actor = ImportAPIActor(modelContainer: modelContainer)
    try await actor.updateEvents(apiEvents)
    return (modelContainer, apiEvents[0].code)
}

#endif
