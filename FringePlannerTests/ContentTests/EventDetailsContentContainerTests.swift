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
}

// MARK: - DetailsStructureTests

extension EventDetailsContentContainerTests.DetailsStructureTests {
    
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
    
    @Suite("Artist Prefix Detection")
    struct ArtistPrefixTests {
        let title = AttributedString("Test Artist: The Show")
        
        @Test("Succeeds on matching prefix")
        func testExactPrefixMatch() {
            #expect(Structure.isArtist(AttributedString("Test Artist"), prefixForTitle: title) == true)
        }
        
        @Test("Succeeds on matching prefix (with trimming)")
        func testPrefixMatchWithTrimming() {
            #expect(Structure.isArtist(AttributedString("  Test Artist  "), prefixForTitle: title) == true)
        }
        
        @Test("Fails on nil artist")
        func testNilArtist() {
            #expect(Structure.isArtist(nil, prefixForTitle: title) == false)
        }
        
        @Test("Fails on non-matching prefix")
        func testNonMatchingPrefix() {
            #expect(Structure.isArtist(AttributedString("Other Artist"), prefixForTitle: title) == false)
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
