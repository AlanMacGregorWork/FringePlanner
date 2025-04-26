//
//  PlannerContentContainer.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 21/04/2025.
//

import SwiftUI
import SwiftData

/// Container for searching planing parts of the fringe trip
struct PlannerContentContainer {
    /// Router type for handling navigation within the planner container
    typealias Router = SimplifiedRouter<NavigationLocation>
}

// MARK: - Content

extension PlannerContentContainer {
    /// Represents the content structure of the planner container
    /// Conforms to `ContentProtocol` to be used within the app's navigation system
    struct Content: ContentProtocol {
        typealias Structure = PlannerContentContainer.Structure
        let router: Router
        let interaction: Interaction
        let dataSource: DataSource
    }
}

// MARK: - Structure
    
extension PlannerContentContainer {
    /// Defines the UI structure of the planner container
    /// Responsible for organising and displaying the content
    struct Structure: StructureProtocol {
        let input: Content
        
        /// The main structure of the planner view
        var structure: some ViewDataProtocol {
            NavigationData(router: input.router) {
                GroupData(type: .form) {
                    nonBookedPerformances
                }
            }
        }
        
        /// Section displaying events that are marked as favourites but not booked
        private var nonBookedPerformances: some ViewDataProtocol {
            GroupData(type: .section(title: "Non-Booked performances")) {
                DatabaseItemsData(
                    predicate: #Predicate<DBFringeEvent> { event in event.isFavourite },
                    elementView: { event in
                        FringeEventData(event: event, onSelected: {
                            input.interaction.openEvent(event)
                        })
                    })
            }
        }
    }
}

// MARK: - Interaction

extension PlannerContentContainer {
    /// Handles user interactions within the planner container
    struct Interaction: InteractionProtocol {
        private let router: Router
        
        /// Creates a new interaction handler with the specified router
        /// - Parameter router: The router to use for navigation
        init(router: Router) {
            self.router = router
        }
        
        /// Opens the details view for the specified fringe event
        /// - Parameter event: The event to display details for
        func openEvent(_ event: DBFringeEvent) {
            router.pushSheet(location: .eventDetails(event.code))
        }
    }
}

// MARK: - DataSource

extension PlannerContentContainer {
    /// Provides data for the planner container
    class DataSource: DataSourceProtocol {
        // Currently empty, will be expanded as needed
    }
}

// MARK: - NavigationLocation

extension PlannerContentContainer {
    /// Defines the possible navigation destinations from the planner container
    enum NavigationLocation: NavigationLocationProtocol {
        /// Shows details for an event with the specified code
        case eventDetails(String)
        
        /// Converts this navigation location to a view
        /// - Parameter constructionHelper: Helper for constructing views
        /// - Returns: The view corresponding to this navigation location
        @ViewBuilder
        @MainActor
        func toView(constructionHelper: ConstructionHelper) -> some View {
            switch self {
            case .eventDetails(let eventCode):
                EventDetailsContentContainer.createContent(
                    eventCode: eventCode,
                    constructionHelper: constructionHelper
                ).buildView()
            }
        }
    }
}

// MARK: - Helper

extension PlannerContentContainer {
    /// Creates the content for the planner container
    /// - Parameter constructionHelper: Helper for constructing views and accessing model container
    /// - Returns: The content for the planner container
    static func createContent(constructionHelper: ConstructionHelper) -> Content {
        let router = Router(constructionHelper: constructionHelper)
        let interaction = Interaction(router: router)
        let dataSource = DataSource()
        return Content(router: router, interaction: interaction, dataSource: dataSource)
    }
}

// MARK: - Preview

#Preview {
    if let modelContainer = try? ModelContainer.create() {
        PlannerContentContainer.createContent(constructionHelper: .init(modelContainer: modelContainer)).buildView()
            .modelContainer(modelContainer)
    } else {
        Text("Failed to generated Container")
    }
}
