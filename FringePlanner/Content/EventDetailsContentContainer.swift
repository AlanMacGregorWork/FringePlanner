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
            switch input.dataSource.content {
            case .noEventFound:
                TextData(text: "Event not found")
            case .eventFound(let event):
                eventStructure(event: event)
            case .databaseError(let error):
                TextData(text: "Database error\n\(error.description)")
            }
        }
        
        @MainActor
        func eventStructure(event: DBFringeEvent) -> some ViewDataProtocol {
            NavigationData(router: input.router, toolbarItems: [
                .favourite(isFavourite: event.isFavourite, onTap: input.interaction.toggleFavourite)
            ]) {
                GroupData(type: .form) {
                    // TODO: Implement proper error handling for the UI
                    if let errorContent = input.dataSource.errorContent {
                        ButtonData(title: errorContent.description, interaction: {
                            input.dataSource.errorContent = nil
                        })
                    }
                    DetailsStructure(event: event)
                    AccessibilityStructure(disabled: event.disabled)
                    DescriptionStructure(event: event)
                }
            }
        }       
    }
}

// MARK: - Data Source

extension EventDetailsContentContainer {
    @Observable
    class DataSource: DataSourceProtocol {
        let content: EventDetailsContent
        var errorContent: ErrorContent?
        
        init(content: EventDetailsContent) {
            self.content = content
        }
    }
}

extension EventDetailsContentContainer.DataSource {
    /// Represents the possible states of event details content
    enum EventDetailsContent { 
        /// No event was found matching the provided event code
        case noEventFound
        /// Event was successfully found and retrieved from the database
        case eventFound(DBFringeEvent)
        /// An error occurred while attempting to retrieve the event from the database
        case databaseError(DBError)

        /// Creates a new event details content state by fetching an event with the provided code
        /// - Parameters:
        ///   - eventCode: The unique identifier code for the event to retrieve
        ///   - constructionHelper: Helper that provides the model container for database access
        init(eventCode: String, constructionHelper: ConstructionHelper) {
            let context = ModelContext(constructionHelper.modelContainer)
            let eventPredicate = #Predicate<DBFringeEvent> { $0.code == eventCode }
            let events: [DBFringeEvent]
            do {
                events = try DBHelper.getDBModels(from: eventPredicate, context: context)
            } catch {
                self = .databaseError(error)
                return
            }
            guard let firstEvent = events.first else {
                fringeAssertFailure("No event found for expected event code: \(eventCode)")
                self = .noEventFound
                return
            }
            self = .eventFound(firstEvent)
        }
    }
}
    
// MARK: - Interaction
    
extension EventDetailsContentContainer {
    struct Interaction: InteractionProtocol {
        let dataSource: DataSource
        
        // MARK: Toggle Favourite
        
        /// Toggles the favourite status of the event
        func toggleFavourite() {
            switch dataSource.content {
            case .eventFound(let event): toggleFavourite(for: event)
            case .databaseError, .noEventFound: break
            }
        }
        
        /// Toggles the favourite status of the event
        private func toggleFavourite(for event: DBFringeEvent) {
            event.isFavourite.toggle()
            
            // ModelContext should exist
            guard let modelContext = event.modelContext else {
                // Reset favourite value & show error
                event.isFavourite.toggle()
                dataSource.errorContent = ErrorContent(error: DBError.missingModelContext)
                return
            }
            
            // Save changes to the parent context
            do {
                try modelContext.save()
            } catch let error {
                // Reset favourite value & show error
                event.isFavourite.toggle()
                dataSource.errorContent = ErrorContent(error: error)
            }
        }
    }
}

// MARK: - Helper

#if DEBUG

extension EventDetailsContentContainer {
    @MainActor
    static func createContent(eventCode: String, constructionHelper: ConstructionHelper) -> Content {
        let dataSourceContent = EventDetailsContentContainer.DataSource.EventDetailsContent(eventCode: eventCode, constructionHelper: constructionHelper)
        let router = Router(constructionHelper: constructionHelper)
        let dataSource = DataSource(content: dataSourceContent)
        let interaction = Interaction(dataSource: dataSource)
        return Content(router: router, interaction: interaction, dataSource: dataSource)
    }
}

// MARK: - Preview

@available(iOS 18, *)
#Preview(traits: .modifier(MockDataPreviewModifier(config: [0: .init(code: .override("demo"))]))) {
    @Previewable @Environment(\.modelContext) var modelContext
    NavigationView {
        EventDetailsContentContainer.createContent(
            eventCode: "demo",
            constructionHelper: .init(modelContainer: modelContext.container)
        ).buildView()
    }
}

#endif
