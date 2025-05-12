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
    typealias Router = SimplifiedRouter<EventDetailsContentContainer.NavigationLocation>
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
                TextData("Event not found")
            case .eventFound(let event):
                eventStructure(event: event)
            case .databaseError(let error):
                TextData("Database error\n\(error.description)")
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
                        DebugButtonData(title: errorContent.description, interaction: {
                            input.dataSource.errorContent = nil
                        })
                    }
                    DetailsStructure(event: event)
                    performancesButton(for: event)
                    AccessibilityStructure(disabled: event.disabled)
                    DescriptionStructure(event: event)
                }
            }
        }       
        
        func performancesButton(for event: DBFringeEvent) -> some ViewDataProtocol {
            ButtonData(interaction: input.interaction.showPerformances, includeNavigationFlair: true) {
                TextData("Performances: \(event.performances.count)")
            }
        }
    }
}

// MARK: - Navigation

extension EventDetailsContentContainer {
    enum NavigationLocation: NavigationLocationProtocol {
        case performances(eventCode: String)
        
        @ViewBuilder
        func toView(constructionHelper: ConstructionHelper) -> some View {
            switch self {
            case .performances(let eventCode):
                PerformancesContentContainer.createContent(
                    eventCode: eventCode,
                    constructionHelper: constructionHelper
                ).buildView()
            }
        }
    }
}

// MARK: - Data Source

extension EventDetailsContentContainer {
    @Observable
    class DataSource: DataSourceProtocol {
        let content: EventContent
        var errorContent: ErrorContent?
        
        init(content: EventContent) {
            self.content = content
        }
    }
}
    
// MARK: - Interaction
    
extension EventDetailsContentContainer {
    struct Interaction: InteractionProtocol {
        let dataSource: DataSource
        let router: EventDetailsContentContainer.Router
        
        func showPerformances() {
            switch dataSource.content {
            case .eventFound(let event): router.pushSheet(location: .performances(eventCode: event.code))
            case .databaseError, .noEventFound: break
            }
        }
        
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
        let dataSourceContent = EventContent(eventCode: eventCode, modelContainer: constructionHelper.modelContainer)
        let router = Router(constructionHelper: constructionHelper)
        let dataSource = DataSource(content: dataSourceContent)
        let interaction = Interaction(dataSource: dataSource, router: router)
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
