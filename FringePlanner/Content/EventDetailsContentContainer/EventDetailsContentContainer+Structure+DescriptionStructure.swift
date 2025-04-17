//
//  EventDetailsContentContainer+Structure+DescriptionStructure.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 27/12/2024.
//

import SwiftUI

extension EventDetailsContentContainer.Structure {
    /// Structure for the description portion of the event details
    struct DescriptionStructure: BaseStructureProtocol {
        let descriptionTeaser: AttributedString.StringProvider?
        let description: AttributedString.StringProvider
        let warnings: AttributedString.StringProvider?
        
        var structure: some ViewDataProtocol {
            GroupData(type: .section) {
                Self.getTeaserRow(from: descriptionTeaser, description: description)
                Self.getDescriptionRow(from: description)
                Self.getWarningsRow(from: warnings)
            }
        }
        
        @FringeDataResultBuilder
        static func getTeaserRow(from teaser: AttributedString.StringProvider?, description: AttributedString.StringProvider) -> some ViewDataProtocol {
            // The teaser should not be shown if it appears in the description, otherwise it will look duplicated.
            if let teaser, !description.hasTrimmedPrefix(teaser) {
                SectionRowData(text: teaser)
            }
        }
        
        @FringeDataResultBuilder
        static func getDescriptionRow(from description: AttributedString.StringProvider) -> some ViewDataProtocol {
            SectionRowData(text: description)
        }
        
        @FringeDataResultBuilder
        static func getWarningsRow(from warnings: AttributedString.StringProvider?) -> some ViewDataProtocol {
            if let warnings {
                SectionRowData(title: "Warnings", text: warnings)
            }
        }
    }
}

extension EventDetailsContentContainer.Structure.DescriptionStructure {
    init(event: DBFringeEvent) {
        self.init(descriptionTeaser: event.descriptionTeaser, description: event.eventDescription, warnings: event.warnings)
    }
    
    init(descriptionTeaser: String?, description: String, warnings: String? ) {
        self.descriptionTeaser = descriptionTeaser.map { AttributedString.StringProvider($0) }
        self.description = AttributedString.StringProvider(description)
        self.warnings = warnings.map { AttributedString.StringProvider($0) }
    }
}
