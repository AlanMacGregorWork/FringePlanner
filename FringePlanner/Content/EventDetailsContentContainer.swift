//
//  EventDetailsContentContainer.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 22/12/2024.
//

import SwiftUI

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
        var event: FringeEvent { input.dataSource.event }
        
        var structure: some ViewDataProtocol {
            GroupData(type: .form) {
                DetailsStructure(event: event)
                AccessibilityStructure(disabled: event.disabled)
                DescriptionStructure(event: event)
            }
        }
    }
}

// MARK: - Data Source

extension EventDetailsContentContainer {
    @Observable
    class DataSource: DataSourceProtocol {
        let event: FringeEvent
        
        init(event: FringeEvent) {
            self.event = event
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
    static func createContent(event: FringeEvent = SeededContent(code: 123).events[0]) -> Content {
        let router = Router()
        let dataSource = DataSource(event: event)
        let interaction = Interaction()
        return Content(router: router, interaction: interaction, dataSource: dataSource)
    }
}

#endif

#Preview {
    EventDetailsContentContainer.createContent().buildView()
}
