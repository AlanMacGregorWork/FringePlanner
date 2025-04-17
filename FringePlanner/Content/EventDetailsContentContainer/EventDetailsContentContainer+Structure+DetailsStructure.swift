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
        let title: AttributedString.StringProvider
        let subTitle: AttributedString.StringProvider?
        let artist: AttributedString.StringProvider?
        let country: AttributedString.StringProvider?
        let ageCategory: AttributedString.StringProvider?
        let genre: AttributedString.StringProvider
        let genreTags: AttributedString.StringProvider?
        
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
                Self.getSubTitleRow(from: subTitle)
                Self.getCountryRow(from: country)
                Self.getAgeCategoryRow(from: ageCategory)
                Self.getGenreRow(from: genre)
                Self.getGenreTagsRow(from: genreTags)
            }
        }

        @FringeDataResultBuilder
        static func getArtistRow(from artist: AttributedString.StringProvider?) -> some ViewDataProtocol {
            if let artist {
                SectionRowData(title: "Artist", text: artist)
            }
        }
        
        @FringeDataResultBuilder
        static func getTitleRow(from title: AttributedString.StringProvider) -> SectionRowData {
            SectionRowData(title: "Title", text: title)
        }

        @FringeDataResultBuilder
        static func getSubTitleRow(from subTitle: AttributedString.StringProvider?) -> some ViewDataProtocol {
            if let subTitle {
                SectionRowData(title: "Subtitle", text: subTitle)
            }
        }
        
        @FringeDataResultBuilder
        static func getArtistAndTitleRow(from artistAndTitle: AttributedString.StringProvider) -> SectionRowData {
            SectionRowData(title: "Artist & Title", text: artistAndTitle)
        }
        
        @FringeDataResultBuilder
        static func getCountryRow(from country: AttributedString.StringProvider?) -> some ViewDataProtocol {
            if let country {
                SectionRowData(title: "Country", text: country)
            }
        }
        
        @FringeDataResultBuilder
        static func getAgeCategoryRow(from ageCategory: AttributedString.StringProvider?) -> some ViewDataProtocol {
            if let ageCategory {
                SectionRowData(title: "Age Category", text: ageCategory)
            }
        }
        
        @FringeDataResultBuilder
        static func getGenreRow(from genre: AttributedString.StringProvider) -> SectionRowData {
            SectionRowData(title: "Genre", text: genre)
        }
        
        @FringeDataResultBuilder
        static func getGenreTagsRow(from genreTags: AttributedString.StringProvider?) -> some ViewDataProtocol {
            if let genreTags {
                SectionRowData(title: "Genre Tags", text: genreTags)
            }
        }
    }
}

extension EventDetailsContentContainer.Structure.DetailsStructure {
    init(event: DBFringeEvent) {
        self.init(
            title: event.title,
            subTitle: event.subTitle,
            artist: event.artist,
            country: event.country,
            ageCategory: event.ageCategory,
            genre: event.genre,
            genreTags: event.genreTags
        )
    }
        
    init(
        title: String,
        subTitle: String?,
        artist: String?,
        country: String?,
        ageCategory: String?,
        genre: String,
        genreTags: String?
    ) {
        self.title = AttributedString.StringProvider(title)
        self.subTitle = subTitle.map { AttributedString.StringProvider($0) }
        self.artist = artist.map { AttributedString.StringProvider($0) }
        self.country = country.map { AttributedString.StringProvider($0) }
        self.ageCategory = ageCategory.map { AttributedString.StringProvider($0) }
        self.genre = AttributedString.StringProvider(genre)
        self.genreTags = genreTags.map { AttributedString.StringProvider($0) }
    }
}
