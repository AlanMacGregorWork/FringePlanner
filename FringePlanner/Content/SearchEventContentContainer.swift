//
//  SearchEventContentContainer.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 26/11/2024.
//

import SwiftUI
import SwiftData
import Combine

/// Container for searching Fringe events
struct SearchEventContentContainer {
    typealias Router = SimplifiedRouter<NavigationLocation>
}

// MARK: - Content

extension SearchEventContentContainer {
    struct Content: ContentProtocol {
        typealias Structure = SearchEventContentContainer.Structure
        let router: Router
        let interaction: Interaction
        let dataSource: DataSource
    }
}

// MARK: - Structure

extension SearchEventContentContainer {
    struct Structure: StructureProtocol {
        let input: Content
        
        var structure: some ViewDataProtocol {
            NavigationData {
                GroupData(type: .form) {
                    GroupData(type: .section) {
                        TextFieldData(text: Bindable(input.dataSource).search)
                        ButtonData(title: "Perform Search", interaction: { input.interaction.performSearch() })
                    }

                    // Displays a list of the events retrieved from the database
                    DatabaseItemsData(
                        predicate: eventCodesPredicate,
                        sortOption: eventSorting,
                        elementView: { event in
                            FringeEventData(event: event, onSelected: { input.interaction.openEvent(event)})
                        }
                    )
                }
            }
        }

        /// Sorting option for the events
        private var eventSorting: DatabaseItemsData<DBFringeEvent, FringeEventData>.DatabaseSortOption {
            .custom({ lhs, rhs in
                // Get the index of each event code in the eventCodes array
                let lhsIndex = input.dataSource.eventCodes.firstIndex(of: lhs.code) ?? Int.max
                let rhsIndex = input.dataSource.eventCodes.firstIndex(of: rhs.code) ?? Int.max
                
                // Sort based on the index position
                return lhsIndex > rhsIndex
            })
        }

        /// Predicate to filter the events by the event codes
        /// - Note: This predicated does not use the `#Predicate` wrapper as it needs not be aware of the `eventCodes`
        private var eventCodesPredicate: Predicate<DBFringeEvent> {
            return Predicate<DBFringeEvent>({
                PredicateExpressions.build_contains(
                    PredicateExpressions.build_Arg(input.dataSource.eventCodes),
                    PredicateExpressions.build_KeyPath(
                        root: PredicateExpressions.build_Arg($0),
                        keyPath: \.code
                    )
                )
            })
        }
    }
}
    
// MARK: - Data Source

extension SearchEventContentContainer {
    @Observable
    class DataSource: DataSourceProtocol {
        let searchSubject: CurrentValueSubject<String, Never>
        var eventCodes: [String] = []
        let modelContainer: ModelContainer
        var search: String {
            didSet {
                guard oldValue != search else { return }
                searchSubject
                    .send(search)
            }
        }
        
        init(search: String = "", modelContainer: ModelContainer) {
            self.search = search
            self.modelContainer = modelContainer
            self.searchSubject = .init(search)
        }
    }
}
    
// MARK: - Interaction
    
extension SearchEventContentContainer {
    struct Interaction: InteractionProtocol {
        private let dataSource: DataSource
        private let router: Router
        private let downloader: FringeEventDownloader.GetEventsProtocol
        private let searchSubjectCancellable: AnyCancellable
        private let modelContainer: ModelContainer
        
        @MainActor
        init(
            dataSource: DataSource,
            router: Router,
            downloader: FringeEventDownloader.GetEventsProtocol = FringeEventDownloader(),
            modelContainer: ModelContainer
        ) {
            self.dataSource = dataSource
            self.router = router
            self.downloader = downloader
            self.modelContainer = modelContainer
            self.searchSubjectCancellable = dataSource.searchSubject
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    Task {
                        await Self.asyncSearch(downloader: downloader, dataSource: dataSource, modelContainer: modelContainer)
                    }
                }
        }
        
        @MainActor
        func openEvent(_ event: DBFringeEvent) {
            router.pushSheet(location: .eventDetails(event.code))
        }
        
        @MainActor
        func performSearch() {
            // Note: Calls out another function to perform the sync as the `Task` will allow
            // any errors thrown to be silenced.
            Task {
                await Self.asyncSearch(downloader: downloader, dataSource: dataSource, modelContainer: modelContainer)
            }
        }
        
        private static func asyncSearch(
            downloader: FringeEventDownloader.GetEventsProtocol,
            dataSource: DataSource,
            modelContainer: ModelContainer
        ) async {
            do {
                // Download the events
                let events = try await downloader.getEvents(from: .init(title: dataSource.search))
                // Import the events into the database
                let importAPIActor = ImportAPIActor(modelContainer: modelContainer)
                try await importAPIActor.updateEvents(events)
                // Inform the data source of the event codes retrieved from the API call
                dataSource.eventCodes = events.map(\.code)
            } catch {
                // TODO: Implement error UI
            }
        }
    }
}

// MARK: -

extension SearchEventContentContainer {
    enum NavigationLocation: NavigationLocationProtocol {
        case eventDetails(String)
        
        @ViewBuilder
        func toView(constructionHelper: ConstructionHelper) -> some View {
            switch self {
            case .eventDetails(let event):
                EventDetailsContentContainer.createContent(
                    eventCode: event,
                    constructionHelper: constructionHelper
                ).buildView()
            }
        }
    }
}

// MARK: - Helper

extension SearchEventContentContainer {
    @MainActor
    static func createContent(constructionHelper: ConstructionHelper) -> Content {
        let downloader = getDownloader()
        let router = Router(constructionHelper: constructionHelper)
        let dataSource = DataSource(modelContainer: constructionHelper.modelContainer)
        let interaction = Interaction(dataSource: dataSource, router: router, downloader: downloader, modelContainer: constructionHelper.modelContainer)
        return Content(router: router, interaction: interaction, dataSource: dataSource)
    }
    
    private static func getDownloader() -> FringeEventDownloader.GetEventsProtocol {
#if DEBUG
        switch ApplicationEnvironment.current {
        case .normal:
            return FringeEventDownloader()
        case .preview, .testingUI, .testingUnit:
            let seededContent = SeededContent(seed: 32)
            let events = seededContent.events()
            return MockEventDownloader(models: events)
        }
#else	
        return FringeEventDownloader()
#endif
    }
}

// MARK: - Preview

#Preview {
    if let modelContainer = try? ModelContainer.create() {
        SearchEventContentContainer.createContent(constructionHelper: .init(modelContainer: modelContainer)).buildView()
            .modelContainer(modelContainer)
    } else {
        Text("Failed to generated Container")
    }
}
