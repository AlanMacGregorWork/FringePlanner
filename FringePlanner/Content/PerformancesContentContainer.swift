//
//  PerformancesContentContainer.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/05/2025.
//

import SwiftUI
import SwiftData

/// Container for displaying performances for an event
struct PerformancesContentContainer {
    typealias Router = SimplifiedRouter<NavigationLocation>
}

// MARK: - Content

extension PerformancesContentContainer {
    struct Content: ContentProtocol {
        typealias Structure = PerformancesContentContainer.Structure
        let router: Router
        let interaction: Interaction
        let dataSource: DataSource
    }
}

// MARK: - Structure

extension PerformancesContentContainer {
    struct Structure: StructureProtocol {
        let input: Content
        var event: DBFringeEvent { input.dataSource.event }
        
        var structure: some ViewDataProtocol {
            NavigationData {
                GroupData(type: .form) {
                    if event.performances.isEmpty {
                        TextData("No performances currently available")
                    } else {
                        let sortedPerformances = event.performances.sorted(by: { $0.start < $1.start })
                        ForEachData(data: sortedPerformances) { performance in
                            ButtonData(
                                interaction: { input.interaction.showPerformance(performance) },
                                includeNavigationFlair: true,
                                content: { FringePerformanceData(performance: performance) })
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Navigation

extension PerformancesContentContainer {
    enum NavigationLocation: NavigationLocationProtocol {
        case performance(performance: DBFringePerformance)
        
        @ViewBuilder
        func toView(constructionHelper: ConstructionHelper) -> some View {
            switch self {
            case .performance(let performance):
                PerformanceContentContainer.createContent(
                    performance: performance,
                    constructionHelper: constructionHelper
                ).buildView()
            }
        }
    }
}

// MARK: - Data Source

extension PerformancesContentContainer {
    @Observable
    class DataSource: DataSourceProtocol {
        let event: DBFringeEvent
        
        init(event: DBFringeEvent) {
            self.event = event
        }
    }
}

// MARK: - Interaction
    
extension PerformancesContentContainer {
    struct Interaction: InteractionProtocol {
        let dataSource: DataSource
        let router: PerformancesContentContainer.Router
        
        func showPerformance(_ performance: DBFringePerformance) {
            router.pushSheet(location: .performance(performance: performance))
        }
    }
}

// MARK: - Helper

#if DEBUG

extension PerformancesContentContainer {
    @MainActor
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
            PerformancesContentContainer.createContent(event: event, constructionHelper: constructionHelper)
                .buildView()
        }
    }
}

#endif
