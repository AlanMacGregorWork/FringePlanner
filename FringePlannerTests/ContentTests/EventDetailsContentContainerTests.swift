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

    @Suite("AccessibilityStructure")
    struct AccessibilityStructureTests {
        typealias Structure = EventDetailsContentContainer.Structure.AccessibilityStructure
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
