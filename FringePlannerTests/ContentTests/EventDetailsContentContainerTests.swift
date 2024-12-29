//
//  EventDetailsContentContainerTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 21/12/2024.
//

import Testing
import Foundation
@testable import FringePlanner

@Suite("Event Details Content Container Tests")
struct EventDetailsContentContainerTests {

    @Suite("DetailsStructure")
    struct DetailsStructureTests {
        typealias Structure = EventDetailsContentContainer.Structure.DetailsStructure
    }
    
    @Suite("AccessibilityStructure")
    struct AccessibilityStructureTests {
        typealias Structure = EventDetailsContentContainer.Structure.AccessibilityStructure
    }
    
    @Suite("DescriptionStructure")
    struct DescriptionStructureTests {
        typealias Structure = EventDetailsContentContainer.Structure.DescriptionStructure
    }
}

// MARK: - DetailsStructureTests

extension EventDetailsContentContainerTests.DetailsStructureTests {
    
    @Suite("Init Tests")
    struct InitTests {                
        @Test("Init converts string to AttributedStrings correctly")
        func testInitConvertsStrings() {
            let details = EventDetailsContentContainer.Structure.DetailsStructure(
                title: "Test <b>Title</b>",
                artist: "Test <i>Artist</i>",
                country: "Test <u>Country</u>",
                ageCategory: "Age <b>12+</b>",
                genre: "Test <b>Genre</b>",
                genreTags: "Tag1, <i>Tag2</i>"
            )
            
            // Verify raw HTML strings are not being used as the final strings
            #expect(details.title != AttributedString("Test <b>Title</b>"))
            #expect(details.artist != AttributedString("Test <i>Artist</i>"))
            #expect(details.country != AttributedString("Test <u>Country</u>"))
            #expect(details.ageCategory != AttributedString("Age <b>12+</b>"))
            #expect(details.genre != AttributedString("Test <b>Genre</b>"))
            #expect(details.genreTags != AttributedString("Tag1, <i>Tag2</i>"))

            // Verify formatting has been applied (ie not just raw strings)
            #expect(details.title != AttributedString("Test Title"))
            #expect(details.artist != AttributedString("Test Artist"))
            #expect(details.country != AttributedString("Test Country"))
            #expect(details.ageCategory != AttributedString("Age 12+"))
            #expect(details.genre != AttributedString("Test Genre"))
            #expect(details.genreTags != AttributedString("Tag1, Tag2"))
            
            // Verify generated AttributedStrings are formatted correctly
            #expect(NSAttributedString(details.title).string == NSAttributedString(AttributedString("Test Title ")).string)
            #expect(details.artist.map(NSAttributedString.init)?.string == NSAttributedString(AttributedString("Test Artist ")).string)
            #expect(details.country.map(NSAttributedString.init)?.string == NSAttributedString(AttributedString("Test Country ")).string)
            #expect(details.ageCategory.map(NSAttributedString.init)?.string == NSAttributedString(AttributedString("Age 12+ ")).string)
            #expect(NSAttributedString(details.genre).string == NSAttributedString(AttributedString("Test Genre ")).string)
            #expect(details.genreTags.map(NSAttributedString.init)?.string == NSAttributedString(AttributedString("Tag1, Tag2 ")).string)
        }
    
    }

    @Suite("General Structure Tests")
    struct GeneralStructureTests {
        @MainActor
        @Test("Structure with minimal content")
        func testMinimalContent() {
            let structure = Structure(
                title: AttributedString("Test Title"),
                artist: nil,
                country: nil,
                ageCategory: nil,
                genre: AttributedString("Comedy"),
                genreTags: nil
            )
            
            structure.expect {
                GroupData(type: .section(title: "Details")) {
                    ContainerData {
                        EmptyData()
                            .conditionalSecond(firstType: SectionRowData.self)
                        SectionRowData(title: "Title", text: AttributedString("Test Title"))
                    }
                    .conditionalSecond(firstType: SectionRowData.self)
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                    SectionRowData(title: "Genre", text: AttributedString("Comedy"))
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                }
            }
        }
        
        @MainActor
        @Test("Structure with all content")
        func testAllContent() {
            let structure = Structure(
                title: AttributedString("Test Title"),
                artist: AttributedString("Test Artist"),
                country: AttributedString("UK"),
                ageCategory: AttributedString("12+"),
                genre: AttributedString("Comedy"),
                genreTags: AttributedString("Stand-up, Improv")
            )
            
            structure.expect {
                GroupData(type: .section(title: "Details")) {
                    ContainerData {
                        SectionRowData(title: "Artist", text: AttributedString("Test Artist"))
                            .conditionalFirst()
                        SectionRowData(title: "Title", text: AttributedString("Test Title"))
                    }
                    .conditionalSecond(firstType: SectionRowData.self)
                    SectionRowData(title: "Country", text: AttributedString("UK"))
                        .conditionalFirst()
                    SectionRowData(title: "Age Category", text: AttributedString("12+"))
                        .conditionalFirst()
                    SectionRowData(title: "Genre", text: AttributedString("Comedy"))
                    SectionRowData(title: "Genre Tags", text: AttributedString("Stand-up, Improv"))
                        .conditionalFirst()
                }
            }
        }
        
        @MainActor
        @Test("Structure with artist prefix in title")
        func testArtistPrefixInTitle() {
            let structure = Structure(
                title: AttributedString("Test Artist: The Show"),
                artist: AttributedString("Test Artist"),
                country: AttributedString("UK"),
                ageCategory: nil,
                genre: AttributedString("Comedy"),
                genreTags: nil
            )
            
            structure.expect {
                GroupData(type: .section(title: "Details")) {
                    SectionRowData(title: "Artist & Title", text: AttributedString("Test Artist: The Show"))
                        .conditionalFirst(secondType: ContainerData<ConditionalData<SectionRowData, EmptyData>, SectionRowData>.self)
                    SectionRowData(title: "Country", text: AttributedString("UK"))
                        .conditionalFirst()
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                    SectionRowData(title: "Genre", text: AttributedString("Comedy"))
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                }
            }
        }
    }
    
    // MARK: - Get Artist Row
    
    @Suite("Get Artist Row")
    struct GetArtistRowTests {
        @Test("Artist exists")
        func testArtistExists() {
            Structure.getArtistRow(from: AttributedString("Test Artist")).expect {
                SectionRowData(title: "Artist", text: AttributedString("Test Artist"))
                    .conditionalFirst()
            }
        }
        
        @Test("Nil artist will not show data")
        func testNilArtist() {
            Structure.getArtistRow(from: nil).expect {
                EmptyData()
                    .conditionalSecond(firstType: SectionRowData.self)
            }
        }
    }
    
    // MARK: - Get Title Row
    
    @Suite("Get Title Row")
    struct GetTitleRowTests {
        @Test("Creates title row")
        func testTitleRow() {
            Structure.getTitleRow(from: AttributedString("Test Title")).expect {
                SectionRowData(title: "Title", text: AttributedString("Test Title"))
            }
        }
    }
    
    // MARK: - Get Artist And Title Row
    
    @Suite("Get Artist And Title Row")
    struct GetArtistAndTitleRowTests {
        @Test("Creates combined row")
        func testCombinedRow() {
            Structure.getArtistAndTitleRow(from: AttributedString("Test Artist: The Show")).expect {
                SectionRowData(title: "Artist & Title", text: AttributedString("Test Artist: The Show"))
            }
        }
    }
    
    // MARK: - Get Country Row
    
    @Suite("Get Country Row")
    struct GetCountryRowTests {
        @Test("Country exists")
        func testCountryExists() {
            Structure.getCountryRow(from: AttributedString("UK")).expect {
                SectionRowData(title: "Country", text: AttributedString("UK"))
                    .conditionalFirst()
            }
        }
        
        @Test("Nil country will not show data")
        func testNilCountry() {
            Structure.getCountryRow(from: nil).expect {
                EmptyData()
                    .conditionalSecond(firstType: SectionRowData.self)
            }
        }
    }
    
    // MARK: - Get Age Category Row
    
    @Suite("Get Age Category Row")
    struct GetAgeCategoryRowTests {
        @Test("Age category exists")
        func testAgeCategoryExists() {
            Structure.getAgeCategoryRow(from: AttributedString("12+")).expect {
                SectionRowData(title: "Age Category", text: AttributedString("12+"))
                    .conditionalFirst()
            }
        }
        
        @Test("Nil age category will not show data")
        func testNilAgeCategory() {
            Structure.getAgeCategoryRow(from: nil).expect {
                EmptyData()
                    .conditionalSecond(firstType: SectionRowData.self)
            }
        }
    }
    
    // MARK: - Get Genre Row
    
    @Suite("Get Genre Row")
    struct GetGenreRowTests {
        @Test("Creates genre row")
        func testGenreRow() {
            Structure.getGenreRow(from: AttributedString("Comedy")).expect {
                SectionRowData(title: "Genre", text: AttributedString("Comedy"))
            }
        }
    }
    
    // MARK: - Get Genre Tags Row
    
    @Suite("Get Genre Tags Row")
    struct GetGenreTagsRowTests {
        @Test("Genre tags exist")
        func testGenreTagsExist() {
            Structure.getGenreTagsRow(from: AttributedString("Stand-up, Improv")).expect {
                SectionRowData(title: "Genre Tags", text: AttributedString("Stand-up, Improv"))
                    .conditionalFirst()
            }
        }
        
        @Test("Nil genre tags will not show data")
        func testNilGenreTags() {
            Structure.getGenreTagsRow(from: nil).expect {
                EmptyData()
                    .conditionalSecond(firstType: SectionRowData.self)
            }
        }
    }
    
}

// MARK: - AccessibilityStructureTests

extension EventDetailsContentContainerTests.AccessibilityStructureTests {
    
    @Suite("General Structure Tests")
    struct GeneralStructureTests {
        @MainActor
        @Test("Structure with no content")
        func testNoContent() {
            let structure = Structure(audio: nil, otherServices: nil, captioningDates: nil, signedDates: nil)
            structure.expect {
                GroupData(type: .section(title: "Accessibility")) {
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                }
            }
        }
        
        @MainActor
        @Test("Structure with all content")
        func testAllContent() {
            let structure = Structure(audio: true, otherServices: false, captioningDates: ["item1", "item2", "item3"], signedDates: ["test1", "test2"])
            structure.expect {
                GroupData(type: .section(title: "Accessibility")) {
                    SectionRowData(title: "Audio Description", text: "Available")
                        .conditionalFirst()
                    SectionRowData(title: "Other Services", text: "Not Available")
                        .conditionalFirst()
                    SectionRowData(title: "Captioning Dates", text: "item1, item2, item3")
                        .conditionalFirst()
                    SectionRowData(title: "Signed Performance Dates", text: "test1, test2")
                        .conditionalFirst()
                }
            }
        }
        
        @MainActor
        @Test("Structure with some content")
        func testSomeContent() {
            let structure = Structure(audio: false, otherServices: nil, captioningDates: [], signedDates: ["date1", "date3"])
            structure.expect {
                GroupData(type: .section(title: "Accessibility")) {
                    SectionRowData(title: "Audio Description", text: "Not Available")
                        .conditionalFirst()
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                    SectionRowData(title: "Captioning Dates", text: "None")
                        .conditionalFirst()
                    SectionRowData(title: "Signed Performance Dates", text: "date1, date3")
                        .conditionalFirst()
                }
            }
        }
    }
    
    // MARK: - Signed Performance Dates
    
    @Suite("Get Signed Dates")
    struct GetSignedSatesTests {
        @Test("Dates creates string")
        func testSomePerformanceDates() {
            Structure.getSignedDates(from: ["test1", "test2"]).expect {
                SectionRowData(title: "Signed Performance Dates", text: "test1, test2")
                    .conditionalFirst()
            }
        }
        
        @Test("Empty dates shows `None`")
        func testEmptyPerformanceDates() {
            Structure.getSignedDates(from: []).expect {
                SectionRowData(title: "Signed Performance Dates", text: "None")
                    .conditionalFirst()
            }
        }
        
        @Test("Nil dates will not show data")
        func testNilPerformanceDates() {
            Structure.getSignedDates(from: nil).expect {
                EmptyData()
                    .conditionalSecond(firstType: SectionRowData.self)
            }
        }
    }
    
    // MARK: - Audio Row
    
    @Suite("Get Audio Row")
    struct GetAudioRowTests {
        @Test("Audio available")
        func testAudioAvailable() {
            Structure.getAudioRow(from: true).expect {
                SectionRowData(title: "Audio Description", text: "Available")
                    .conditionalFirst()
            }
        }
        
        @Test("Audio not available")
        func testAudioNotAvailable() {
            Structure.getAudioRow(from: false).expect {
                SectionRowData(title: "Audio Description", text: "Not Available")
                    .conditionalFirst()
            }
        }
        
        @Test("Nil audio will not show data")
        func testNilAudio() {
            Structure.getAudioRow(from: nil).expect {
                EmptyData()
                    .conditionalSecond(firstType: SectionRowData.self)
            }
        }
    }
    
    // MARK: - Other Services
    
    @Suite("Get Other Services")
    struct GetOtherServicesTests {
        @Test("Other services available")
        func testOtherServicesAvailable() {
            Structure.getOtherServices(from: true).expect {
                SectionRowData(title: "Other Services", text: "Available")
                    .conditionalFirst()
            }
        }
        
        @Test("Other services not available")
        func testOtherServicesNotAvailable() {
            Structure.getOtherServices(from: false).expect {
                SectionRowData(title: "Other Services", text: "Not Available")
                    .conditionalFirst()
            }
        }
        
        @Test("Nil other services will not show data")
        func testNilOtherServices() {
            Structure.getOtherServices(from: nil).expect {
                EmptyData()
                    .conditionalSecond(firstType: SectionRowData.self)
            }
        }
    }
    
    // MARK: - Captioning Dates
    
    @Suite("Get Captioning Dates")
    struct GetCaptioningDatesTests {
        @Test("Dates creates string")
        func testSomeCaptioningDates() {
            Structure.getCaptioningDates(from: ["date1", "date2"]).expect {
                SectionRowData(title: "Captioning Dates", text: "date1, date2")
                    .conditionalFirst()
            }
        }
        
        @Test("Empty dates shows `None`")
        func testEmptyCaptioningDates() {
            Structure.getCaptioningDates(from: []).expect {
                SectionRowData(title: "Captioning Dates", text: "None")
                    .conditionalFirst()
            }
        }
        
        @Test("Nil dates will not show data")
        func testNilCaptioningDates() {
            Structure.getCaptioningDates(from: nil).expect {
                EmptyData()
                    .conditionalSecond(firstType: SectionRowData.self)
            }
        }
    }
}

// MARK: - DescriptionStructureTests

extension EventDetailsContentContainerTests.DescriptionStructureTests {
    
    @Suite("Init Tests")
    struct InitTests {
        @Test("Init converts string to AttributedStrings correctly")
        func testInitConvertsStrings() {
            let description = Structure(
                descriptionTeaser: "Test <b>Teaser</b>",
                description: "Test <i>Description</i>",
                warnings: "Test <u>Warning</u>"
            )
            
            // Verify raw HTML strings are not being used as the final strings
            #expect(description.descriptionTeaser != AttributedString("Test <b>Teaser</b>"))
            #expect(description.description != AttributedString("Test <i>Description</i>"))
            #expect(description.warnings != AttributedString("Test <u>Warning</u>"))
            
            // Verify formatting has been applied (ie not just raw strings)
            #expect(description.descriptionTeaser != AttributedString("Test Teaser"))
            #expect(description.description != AttributedString("Test Description"))
            #expect(description.warnings != AttributedString("Test Warning"))
            
            // Verify generated AttributedStrings are formatted correctly
            #expect(description.descriptionTeaser.map(NSAttributedString.init)?.string == NSAttributedString(AttributedString("Test Teaser ")).string)
            #expect(NSAttributedString(description.description).string == NSAttributedString(AttributedString("Test Description ")).string)
            #expect(description.warnings.map(NSAttributedString.init)?.string == NSAttributedString(AttributedString("Test Warning ")).string)
        }
    }
    
    @Suite("General Structure Tests")
    struct GeneralStructureTests {
        @MainActor
        @Test("Structure with minimal content")
        func testMinimalContent() {
            let structure = Structure(
                descriptionTeaser: nil,
                description: AttributedString("Test Description"),
                warnings: nil
            )
            
            structure.expect {
                GroupData(type: .section) {
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                    SectionRowData(text: AttributedString("Test Description"))
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                }
            }
        }
        
        @MainActor
        @Test("Structure with all content")
        func testAllContent() {
            let structure = Structure(
                descriptionTeaser: AttributedString("Test Teaser"),
                description: AttributedString("Test Description"),
                warnings: AttributedString("Test Warning")
            )
            
            structure.expect {
                GroupData(type: .section) {
                    SectionRowData(text: AttributedString("Test Teaser"))
                        .conditionalFirst()
                    SectionRowData(text: AttributedString("Test Description"))
                    SectionRowData(title: "Warnings", text: AttributedString("Test Warning"))
                        .conditionalFirst()
                }
            }
        }
        
        @MainActor
        @Test("Structure with teaser included in description")
        func testTeaserIncludedInDescription() {
            let teaser = AttributedString("Test Teaser")
            let description = AttributedString("Test Teaser followed by more text")
            
            let structure = Structure(
                descriptionTeaser: teaser,
                description: description,
                warnings: nil
            )
            
            structure.expect {
                GroupData(type: .section) {
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                    SectionRowData(text: AttributedString("Test Teaser followed by more text"))
                    EmptyData()
                        .conditionalSecond(firstType: SectionRowData.self)
                }
            }
        }
    }
    
    // MARK: - Get Teaser Row
    
    @Suite("Get Teaser Row")
    struct GetTeaserRowTests {
        @Test("Returns row if teaser exists and not prefix of description")
        func testTeaserExistsAndNotPrefixOfDescription() {
            let teaser = AttributedString("Test Teaser")
            let description = AttributedString("Some Other Description")
            Structure.getTeaserRow(from: teaser, description: description).expect {
                SectionRowData(text: AttributedString("Test Teaser"))
                    .conditionalFirst()
            }
        }
        
        @Test("Returns empty if teaser does not exist")
        func testNoTeaser() {
            let description = AttributedString("Some Other Description")
            Structure.getTeaserRow(from: nil, description: description).expect {
                EmptyData()
                    .conditionalSecond(firstType: SectionRowData.self)
            }
        }
        
        @Test("Returns empty if teaser is prefix of description")
        func testTeaserIsPrefix() {
            let teaser = AttributedString("Test Teaser")
            let description = AttributedString("Test Teaser Description")
            Structure.getTeaserRow(from: teaser, description: description).expect {
                EmptyData()
                    .conditionalSecond(firstType: SectionRowData.self)
            }
        }
    }
    
    // MARK: - Get Description Row
    
    @Suite("Get Description Row")
    struct GetDescriptionRowTests {
        @Test("Returns description row")
        func testDescriptionRow() {
            Structure.getDescriptionRow(from: AttributedString("Test Description")).expect {
                SectionRowData(text: AttributedString("Test Description"))
            }
        }
    }
    
    // MARK: - Get Warnings Row
    
    @Suite("Get Warnings Row")
    struct GetWarningsRowTests {
        @Test("Row returned with warning")
        func testWarningsExist() {
            Structure.getWarningsRow(from: AttributedString("Test Warning")).expect {
                SectionRowData(title: "Warnings", text: AttributedString("Test Warning"))
                    .conditionalFirst()
            }
        }
        
        @Test("EmptyData returned without warning")
        func testNilWarnings() {
            Structure.getWarningsRow(from: nil).expect {
                EmptyData()
                    .conditionalSecond(firstType: SectionRowData.self)
            }
        }
    }
}
