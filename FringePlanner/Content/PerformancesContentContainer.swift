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
        
        var structure: some ViewDataProtocol {
            switch input.dataSource.content {
            case .success(let event):
                performances(for: event)
            case .failure(let error):
                TextData("Database error\n\(error.description)")
            }
        }
        
        @MainActor
        func performances(for event: DBFringeEvent) -> some ViewDataProtocol {
            NavigationData(router: input.router) {
                GroupData(type: .form) {
                    if event.performances.isEmpty {
                        TextData("No performances currently available")
                    } else {
                        let sortedPerformances = event.performances.sorted(by: { $0.start < $1.start })
                        ForEachData(data: sortedPerformances) { performance in
                            ButtonData(
                                interaction: { input.interaction.showPerformance(referenceID: performance.referenceID) },
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
        case performance(referenceID: String)
        
        @ViewBuilder
        func toView(constructionHelper: ConstructionHelper) -> some View {
            switch self {
            case .performance(let referenceID):
                PerformanceContentContainer.createContent(
                    referenceID: referenceID,
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
        let content: Result<DBFringeEvent, DBError>
        var errorContent: ErrorContent?
        
        init(content: Result<DBFringeEvent, DBError>) {
            self.content = content
        }
    }
}

// MARK: - Interaction
    
extension PerformancesContentContainer {
    struct Interaction: InteractionProtocol {
        let dataSource: DataSource
        let router: PerformancesContentContainer.Router
        
        func showPerformance(referenceID: String) {
            router.pushSheet(location: .performance(referenceID: referenceID))
        }
    }
}

// MARK: - Helper

#if DEBUG

extension PerformancesContentContainer {
    @MainActor
    static func createContent(eventCode: String, constructionHelper: ConstructionHelper) -> Content {
        let context = ModelContext(constructionHelper.modelContainer)
        let dataSourceContent = PredicateHelper.event(eventCode: eventCode).getWrappedContent(context: context)
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
        PerformancesContentContainer.createContent(
            eventCode: "demo",
            constructionHelper: .init(modelContainer: modelContext.container)
        ).buildView()
    }
}

#endif
