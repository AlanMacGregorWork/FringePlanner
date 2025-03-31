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
            NavigationData(router: input.router) {
                GroupData(type: .form) {
                    GroupData(type: .section) {
                        TextFieldData(text: Bindable(input.dataSource).search)
                        ButtonData(title: "Perform Search", interaction: { input.interaction.performSearch() })
                    }
                    
                    GroupData(type: .section) {
                        ForEachData(data: input.dataSource.events) { event in
                            ButtonData(title: event.title, interaction: { input.interaction.openEvent(event) })
                        }
                    }
                }
            }
        }
    }
}
    
// MARK: - Data Source

extension SearchEventContentContainer {
    @Observable
    class DataSource: DataSourceProtocol {
        let searchSubject: CurrentValueSubject<String, Never>
        var events: [FringeEvent] = .exampleModels()
        var search: String {
            didSet {
                guard oldValue != search else { return }
                searchSubject
                    .send(search)
            }
        }
        
        init(search: String = "") {
            self.search = search
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
        func openEvent(_ event: FringeEvent) {
            router.pushSheet(location: .eventDetails(event))
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
                let events = try await downloader.getEvents(from: .init(title: dataSource.search))
                let importAPIActor = ImportAPIActor(modelContainer: modelContainer)
                try await importAPIActor.updateEvents(events)
                dataSource.events = events
            } catch {
                // TODO: Implement error UI
            }
        }
    }
}

// MARK: -

extension SearchEventContentContainer {
    enum NavigationLocation: NavigationLocationProtocol {
        case eventDetails(FringeEvent)
        
        @ViewBuilder
        func toView() -> some View {
            switch self {
            case .eventDetails(let event):
                EventDetailsContentContainer.createContent(event: event).buildView()
            }
        }
    }
}

// MARK: - Helper

extension SearchEventContentContainer {
    @MainActor
    static func createContent(modelContainer: ModelContainer) -> Content {
        let downloader = getDownloader()
        let router = Router()
        let dataSource = DataSource()
        let interaction = Interaction(dataSource: dataSource, router: router, downloader: downloader, modelContainer: modelContainer)
        return Content(router: router, interaction: interaction, dataSource: dataSource)
    }
    
    private static func getDownloader() -> FringeEventDownloader.GetEventsProtocol {
#if DEBUG
        switch ApplicationEnvironment.current {
        case .normal:
            return FringeEventDownloader()
        case .preview, .testingUI, .testingUnit:
            return MockEventDownloader()
        }
#else	
        return FringeEventDownloader()
#endif
    }
}

// MARK: - Preview

#Preview {
    if let modelContainer = try? ModelContainer.create() {
        SearchEventContentContainer.createContent(modelContainer: modelContainer).buildView()
    } else {
        Text("Failed to generated Container")
    }
}
