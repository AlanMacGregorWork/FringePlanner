//
//  EventDetailsContentContainer+Structure+DetailsStructure.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 24/12/2024.
//

import SwiftUI

extension EventDetailsContentContainer.Structure {
    /// Structure for the general details portion of the event details
    struct DetailsStructure: BaseStructureProtocol {
        let title: AttributedString
        let artist: AttributedString?
        let country: AttributedString?
        let ageCategory: AttributedString?
        let genre: AttributedString
        let genreTags: AttributedString?
        
        var structure: some ViewDataProtocol {
            GroupData(type: .section(title: "Details")) {
                // Artists will often be included in the prefix of the title, in these situations the
                // artist row will be removed and a row showing the Artist & Title will be displayed
                if title.hasTrimmedPrefix(artist) {
                    Self.getArtistAndTitleRow(from: title)
                } else {
                    Self.getArtistRow(from: artist)
                    Self.getTitleRow(from: title)
                }
                Self.getCountryRow(from: country)
                Self.getAgeCategoryRow(from: ageCategory)
                Self.getGenreRow(from: genre)
                Self.getGenreTagsRow(from: genreTags)
            }
        }

        @FringeDataResultBuilder
        static func getArtistRow(from artist: AttributedString?) -> some ViewDataProtocol {
            if let artist {
                SectionRowData(title: "Artist", text: artist)
            }
        }
        
        @FringeDataResultBuilder
        static func getTitleRow(from title: AttributedString) -> SectionRowData {
            SectionRowData(title: "Title", text: title)
        }
        
        @FringeDataResultBuilder
        static func getArtistAndTitleRow(from artistAndTitle: AttributedString) -> SectionRowData {
            SectionRowData(title: "Artist & Title", text: artistAndTitle)
        }
        
        @FringeDataResultBuilder
        static func getCountryRow(from country: AttributedString?) -> some ViewDataProtocol {
            if let country {
                SectionRowData(title: "Country", text: country)
            }
        }
        
        @FringeDataResultBuilder
        static func getAgeCategoryRow(from ageCategory: AttributedString?) -> some ViewDataProtocol {
            if let ageCategory {
                SectionRowData(title: "Age Category", text: ageCategory)
            }
        }
        
        @FringeDataResultBuilder
        static func getGenreRow(from genre: AttributedString) -> SectionRowData {
            SectionRowData(title: "Genre", text: genre)
        }
        
        @FringeDataResultBuilder
        static func getGenreTagsRow(from genreTags: AttributedString?) -> some ViewDataProtocol {
            if let genreTags {
                SectionRowData(title: "Genre Tags", text: genreTags)
            }
        }
    }
}

extension EventDetailsContentContainer.Structure.DetailsStructure {
    init(event: FringeEvent) {
        self.init(
            title: event.title,
            artist: event.artist,
            country: event.country,
            ageCategory: event.ageCategory,
            genre: event.genre,
            genreTags: event.genreTags
        )
    }
        
    init(
        title: String,
        artist: String?,
        country: String?,
        ageCategory: String?,
        genre: String,
        genreTags: String?
    ) {
        self.title = AttributedString(fromHTML: title) ?? AttributedString(title)
        self.artist = artist.map { AttributedString(fromHTML: $0) ?? AttributedString($0) }
        self.country = country.map { AttributedString(fromHTML: $0) ?? AttributedString($0) }
        self.ageCategory = ageCategory.map { AttributedString(fromHTML: $0) ?? AttributedString($0) }
        self.genre = AttributedString(fromHTML: genre) ?? AttributedString(genre)
        self.genreTags = genreTags.map { AttributedString(fromHTML: $0) ?? AttributedString($0) }
    }
}
