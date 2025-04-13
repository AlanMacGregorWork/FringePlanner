//
//  DatabaseItemsData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 06/04/2025.
//

import SwiftData
import SwiftUI
import Foundation

/// Displays items from the database
struct DatabaseItemsData<Element: PersistentModel, ElementViewData: ViewDataProtocol>: ViewDataProtocol, Equatable {
    let predicate: Predicate<Element>
    let elementView: ((Element) -> ElementViewData)
    let sortOption: DatabaseSortOption
    
    init(
        predicate: Predicate<Element>, 
        sortOption: DatabaseSortOption = .noSorting, 
        elementView: @escaping (Element) -> ElementViewData
    ) {
        self.predicate = predicate
        self.sortOption = sortOption
        self.elementView = elementView
    }

    // MARK: Equatable
        
    static func == (lhs: Self, rhs: Self) -> Bool {
        // Note: Purposely omitting elementView
        guard lhs.predicate.description == rhs.predicate.description else { return false }
        guard lhs.sortOption == rhs.sortOption else { return false }
        return true
    }
}

// MARK: - Content View

extension DatabaseItemsData {
    struct ContentView: View, ViewProtocol {
        @Query var models: [Element]
        let data: DatabaseItemsData<Element, ElementViewData>
        // A cache for the ViewData models
        @State private var processedViewData: [Element.ID: ElementViewData] = [:]

        init(data: DatabaseItemsData<Element, ElementViewData>) {
            // Set the sorting of the models at the database level if possible
            switch data.sortOption { 
            case .noSorting, .custom:
                self._models = Query(filter: data.predicate)
            case .sortDescriptor(let sortDescriptor):
                self._models = Query(filter: data.predicate, sort: sortDescriptor)
            }
                
            self.data = data
        }
    
        var body: some View {
            ForEach(sortedModels) { model in
                // Some UI elements (such as the AttributedString) must be processed on the main thread
                // so we need to ensure that the view data is processed outside of the view update cycle
                
                // If the view data has already been processed, use the cached version
                if let cachedViewData = processedViewData[model.id] {
                    cachedViewData.createView()
                } else {
                    Color.clear
                        .task(id: model.id) {
                            // Process the view data outside the view update cycle
                            let viewData = data.elementView(model)
                            await MainActor.run { processedViewData[model.id] = viewData }
                        }
                }
            }
            .onChange(of: models) {
                // Clear cache when models change
                processedViewData.removeAll()
            }
        }

        var sortedModels: [Element] {
            switch data.sortOption {
            case .custom(let comparator):
                return models.sorted(by: comparator)
            case .sortDescriptor, .noSorting:
                // `sortDescriptor` is used inside of the `init`
                return models
            }
        }
    }
}

// MARK: - Enums

extension DatabaseItemsData {

    /// The option for sorting the database items
    enum DatabaseSortOption: Equatable {
        /// No sorting
        case noSorting
        /// Custom sorting 
        /// - Note: Will sort after retrieving the models from the database
        case custom((Element, Element) -> Bool)
        /// Sorting using a sort descriptor
        /// - Note: Will sort whilst retrieving the models from the database
        case sortDescriptor([SortDescriptor<Element>])
        
        static func == (lhs: DatabaseSortOption, rhs: DatabaseSortOption) -> Bool {
            // Note: `==` being handled manually as `custom` is not equatable
            switch (lhs, rhs) {
            case (.noSorting, .noSorting):
                return true
            case (.custom, .custom):
                return true
            case (.sortDescriptor(let lhsSortDescriptor), .sortDescriptor(let rhsSortDescriptor)):
                return lhsSortDescriptor.description == rhsSortDescriptor.description
            default: return false
            }
        }
    }
}
