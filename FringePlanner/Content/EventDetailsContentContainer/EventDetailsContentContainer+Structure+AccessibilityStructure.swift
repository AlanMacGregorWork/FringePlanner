//
//  EventDetailsContentContainer+Structure+AccessibilityStructure.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 22/12/2024.
//

extension EventDetailsContentContainer.Structure {
    /// Structure for the accessibility portion of the event details
    struct AccessibilityStructure: BaseStructureProtocol {
        let audio: Bool?
        let otherServices: Bool?
        let captioningDates: [String]?
        let signedDates: [String]?
        
        var structure: some ViewDataProtocol {
            GroupData(type: .section(title: "Accessibility")) {
                Self.getAudioRow(from: audio)
                Self.getOtherServices(from: otherServices)
                Self.getCaptioningDates(from: captioningDates)
                Self.getSignedDates(from: signedDates)
            }
        }
        
        @FringeDataResultBuilder
        static func getAudioRow(from audio: Bool?) -> some ViewDataProtocol {
            if let audio {
                SectionRowData(title: "Audio Description", text: audio ? "Available" : "Not Available")
            }
        }
        
        @FringeDataResultBuilder
        static func getOtherServices(from otherServices: Bool?) -> some ViewDataProtocol {
            if let otherServices {
                SectionRowData(title: "Other Services", text: otherServices ? "Available" : "Not Available")
            }
        }
        
        @FringeDataResultBuilder
        static func getCaptioningDates(from captioningDates: [String]?) -> some ViewDataProtocol {
            if let captioningDates {
                let text = captioningDates.joined(separator: ", ").nilOnEmpty ?? "None"
                SectionRowData(title: "Captioning Dates", text: text)
            }
        }
        
        @FringeDataResultBuilder
        static func getSignedDates(from signedDates: [String]?) -> some ViewDataProtocol {
            if let signedDates {
                let text = signedDates.joined(separator: ", ").nilOnEmpty ?? "None"
                SectionRowData(title: "Signed Performance Dates", text: text)
            }
        }
    }
}

extension EventDetailsContentContainer.Structure.AccessibilityStructure {
    init(disabled: FBDisabled?) {
        self.audio = disabled?.audio
        self.otherServices = disabled?.otherServices
        self.captioningDates = disabled?.captioningDates
        self.signedDates = disabled?.signedDates
    }
}
