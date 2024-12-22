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
            let expected = Structure.getSignedDates(from: ["test1", "test2"])
            #expect(expected == .init(option: .first(SectionRowData(title: "Signed Performance Dates", text: "test1, test2"))))
        }
        
        @Test("Empty dates shows `None`")
        func testEmptyPerformanceDates() {
            let expected = Structure.getSignedDates(from: [])
            #expect(expected == .init(option: .first(SectionRowData(title: "Signed Performance Dates", text: "None"))))
        }
        
        @Test("Nil dates will not show data")
        func testNilPerformanceDates() {
            let expected = Structure.getSignedDates(from: nil)
            #expect(expected == .init(option: .second(EmptyData())))
        }
    }
    
    // MARK: - Audio Row
    
    @Suite("Get Audio Row")
    struct GetAudioRowTests {
        @Test("Audio available")
        func testAudioAvailable() {
            let expected = Structure.getAudioRow(from: true)
            #expect(expected == .init(option: .first(SectionRowData(title: "Audio Description", text: "Available"))))
        }
        
        @Test("Audio not available")
        func testAudioNotAvailable() {
            let expected = Structure.getAudioRow(from: false)
            #expect(expected == .init(option: .first(SectionRowData(title: "Audio Description", text: "Not Available"))))
        }
        
        @Test("Nil audio will not show data")
        func testNilAudio() {
            let expected = Structure.getAudioRow(from: nil)
            #expect(expected == .init(option: .second(EmptyData())))
        }
    }
    
    // MARK: - Other Services
    
    @Suite("Get Other Services")
    struct GetOtherServicesTests {
        @Test("Other services available")
        func testOtherServicesAvailable() {
            let expected = Structure.getOtherServices(from: true)
            #expect(expected == .init(option: .first(SectionRowData(title: "Other Services", text: "Available"))))
        }
        
        @Test("Other services not available")
        func testOtherServicesNotAvailable() {
            let expected = Structure.getOtherServices(from: false)
            #expect(expected == .init(option: .first(SectionRowData(title: "Other Services", text: "Not Available"))))
        }
        
        @Test("Nil other services will not show data")
        func testNilOtherServices() {
            let expected = Structure.getOtherServices(from: nil)
            #expect(expected == .init(option: .second(EmptyData())))
        }
    }
    
    // MARK: - Captioning Dates
    
    @Suite("Get Captioning Dates")
    struct GetCaptioningDatesTests {
        @Test("Dates creates string")
        func testSomeCaptioningDates() {
            let expected = Structure.getCaptioningDates(from: ["date1", "date2"])
            #expect(expected == .init(option: .first(SectionRowData(title: "Captioning Dates", text: "date1, date2"))))
        }
        
        @Test("Empty dates shows `None`")
        func testEmptyCaptioningDates() {
            let expected = Structure.getCaptioningDates(from: [])
            #expect(expected == .init(option: .first(SectionRowData(title: "Captioning Dates", text: "None"))))
        }
        
        @Test("Nil dates will not show data")
        func testNilCaptioningDates() {
            let expected = Structure.getCaptioningDates(from: nil)
            #expect(expected == .init(option: .second(EmptyData())))
        }
    }
}
