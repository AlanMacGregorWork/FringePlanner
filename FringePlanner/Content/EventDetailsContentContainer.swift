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
        var event: DBFringeEvent { input.dataSource.event }
        
        var structure: some ViewDataProtocol {
            NavigationData(toolbarItems: [
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
        case performances(event: DBFringeEvent)
        
        @ViewBuilder
        func toView(constructionHelper: ConstructionHelper) -> some View {
            switch self {
            case .performances(let event):
                PerformancesContentContainer.createContent(
                    event: event,
                    constructionHelper: constructionHelper
                )
                .buildView()
            }
        }
    }
}

// MARK: - Data Source

extension EventDetailsContentContainer {
    @Observable
    class DataSource: DataSourceProtocol {
        let event: DBFringeEvent
        var errorContent: ErrorContent?
        
        init(event: DBFringeEvent) {
            self.event = event
        }
    }
}
    
// MARK: - Interaction
    
extension EventDetailsContentContainer {
    struct Interaction: InteractionProtocol {
        let dataSource: DataSource
        let router: EventDetailsContentContainer.Router
        
        func showPerformances() {
            router.pushSheet(location: .performances(event: dataSource.event))
        }
        
        // MARK: Toggle Favourite
        
        /// Toggles the favourite status of the event
        func toggleFavourite() {
            toggleFavourite(for: dataSource.event)
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
    static func createContent(event: DBFringeEvent, constructionHelper: ConstructionHelper) -> Content {
        let router = Router(constructionHelper: constructionHelper)
        let dataSource = DataSource(event: event)
        let interaction = Interaction(dataSource: dataSource, router: router)
        return Content(router: router, interaction: interaction, dataSource: dataSource)
    }
}

// MARK: - Preview

@available(iOS 18, *)
#Preview(traits: .modifier(MockDataPreviewModifier(config: [0: .init(code: .override("demo"))]))) {
    @Previewable @Environment(\.modelContext) var modelContext
    NavigationView {
        PreviewEventFromDatabaseView(eventCode: "demo") { event in
            let constructionHelper = ConstructionHelper(modelContainer: modelContext.container)
            EventDetailsContentContainer.createContent(event: event, constructionHelper: constructionHelper)
                .buildView()
        }
    }
}

#endif
