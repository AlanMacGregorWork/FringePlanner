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
    typealias Router = SimplifiedRouter<BasicNavigationLocation>
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
            case .noEventFound:
                TextData(text: "Event not found")
            case .eventFound(let event):
                performances(for: event)
            case .databaseError(let error):
                TextData(text: "Database error\n\(error.description)")
            }
        }
        
        @MainActor
        func performances(for event: DBFringeEvent) -> some ViewDataProtocol {
            GroupData(type: .form) {
                if event.performances.isEmpty {
                    TextData(text: "No performances currently available")
                } else {
                    ForEachData(data: event.performances) { performance in
                        TextData(text: performance.referenceID)
                    }
                }
            }
        }
    }
}

// MARK: - Data Source

extension PerformancesContentContainer {
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
    
extension PerformancesContentContainer {
    struct Interaction: InteractionProtocol {
        let dataSource: DataSource
    }
}

// MARK: - Helper

#if DEBUG

extension PerformancesContentContainer {
    @MainActor
    static func createContent(eventCode: String, constructionHelper: ConstructionHelper) -> Content {
        let dataSourceContent = EventContent(eventCode: eventCode, modelContainer: constructionHelper.modelContainer)
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
        PerformancesContentContainer.createContent(
            eventCode: "demo",
            constructionHelper: .init(modelContainer: modelContext.container)
        ).buildView()
    }
}

#endif
