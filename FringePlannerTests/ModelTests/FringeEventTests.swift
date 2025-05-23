//
//  FringeEventTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 04/11/2024.
//

import Testing
import Foundation
@testable import FringePlanner

@Suite("FringeEvent Tests")
struct FringeEventTests {
    
    // MARK: Properties

    private let testDataContent: TestDataContent
    
    // MARK: Init
    
    init() throws {
        self.testDataContent = try TestDataContent()
    }
    
    // MARK: Tests (Verify)
    
    @Test("All json keys exist in `expectedValues`", arguments: TestDataContent.allJsonKeysSafe)
    func verifyAllJsonKeysHaveATest(_ key: String) {
        #expect(TestDataContent.expectedValues.keys.contains(where: { $0 == key }), "No test for Json key `\(key)`")
    }
    
    @Test("All test keys exist in json", arguments: TestDataContent.expectedValues.keys)
    func verifyOnlyMatchingTestKeysExist(_ key: String) {
        let jsonKeys = testDataContent.allJsonKeys
        #expect(jsonKeys.contains(key), "`\(key)` not found in json")
    }
    
    @Test("All test keys have unique key paths", arguments: TestDataContent.expectedValues.keys)
    func verifyAllTestKeysHaveUniqueKeyPaths(_ key: String) throws {
        let value = try #require(TestDataContent.expectedValues[key])
        guard let id = value?.id as? String else { return }
        #expect(TestDataContent.expectedValues.values.count(where: { $0?.id as? String == id }) == 1, "`\(key)` is not unique")
    }
    
    // MARK: Test (Types)
    
    @Test("Test expected values", arguments: TestDataContent.expectedValues.keys)
    func testExpectedData(_ key: String) throws {
        // Function to enumerate through test data and equate with the decoded value
        func testValues<T: Equatable>(for testData: TestData<T>) {
            let responsesAsArray = (0..<4).map { testDataContent.decodedResponse[$0][keyPath: testData.keyPath] }
            #expect(responsesAsArray == testData.array)
        }
        
        // Cast through each of the types to execute tests
        let value = try #require(TestDataContent.expectedValues[key])
        guard let value = value else { return }
        let castedTests = [
            (value as? TestData<String>).map(testValues(for:)),
            (value as? TestData<String?>).map(testValues(for:)),
            (value as? TestData<FringeStatus>).map(testValues(for:)),
            (value as? TestData<URL>).map(testValues(for:)),
            (value as? TestData<Date>).map(testValues(for:)),
            (value as? TestData<Int>).map(testValues(for:)),
            (value as? TestData<FringeDisabled?>).map(testValues(for:)),
            (value as? TestData<FringePerformanceSpace>).map(testValues(for:)),
            (value as? TestData<FringeVenue>).map(testValues(for:)),
            (value as? TestData<[String: FringeImage]>).map(testValues(for:)),
            (value as? TestData<[FringePerformance]>).map(testValues(for:))
        ]
        guard castedTests.contains(where: { $0 != nil }) else {
            // If this is triggered another type will need adding to the switch
            enum TestDataError: Error {
                case testKeyNotHandled(key: String)
            }
            throw TestDataError.testKeyNotHandled(key: key)
        }
    }
}

// MARK: - TestData

private struct TestData<T: Equatable & Sendable>: Identifiable {
    let keyPath: KeyPath<FringeEvent, T>
    let array: [T]
    var id: String { "\(keyPath)" }
}

// MARK: - TestDataContent

/// Contains test information from the json assets
private struct TestDataContent {
    let dataResponse: Data
    let decodedResponse: [FringeEvent]
    let jsonResponse: [[String: Any]]
    var allJsonKeys: Set<String> { Set(jsonResponse.flatMap { $0.keys }) }
    static let allJsonKeysSafe: [String] = Array((try? TestDataContent())?.allJsonKeys ?? []).sorted(by: { $0 < $1 })
    
    enum InitErrors: Error {
        case failedToGetResponseData(Bundle.GetTestDataError)
        case failedToDecodeData(DecodingError?)
    }
    
    init() throws(InitErrors) {
        self.dataResponse = try mapError(
            for: try Bundle.testData(name: "eventResponse"),
            expectedType: Data.self,
            to: { (error: Bundle.GetTestDataError) in InitErrors.failedToGetResponseData(error) })
        
        self.decodedResponse = try mapError(
            for: try fringeJsonDecoder.decode([FringeEvent].self, from: self.dataResponse),
            expectedType: [FringeEvent].self,
            to: { (error: Error) in InitErrors.failedToDecodeData(error as? DecodingError) })
        
        guard let json = try? JSONSerialization.jsonObject(with: self.dataResponse) as? [[String: Any]] else {
            throw .failedToDecodeData(nil)
        }
        self.jsonResponse = json
    }
    
    /// A array of the the expected response from the decoded JSON
    static let expectedValues: [String: (any Identifiable & Sendable)?] = [
        "title": TestData(keyPath: \.title, array: ["Normal Value", "Trim", "TrimNewLine", "lowercase"]),
        "sub_title": TestData(keyPath: \.subTitle, array: ["Other", "Fake1", "Fake2", nil]),
        "genre": TestData(keyPath: \.genre, array: ["Normal Value", "Trim", "TrimNewLine", "lowercase"]),
        "code": TestData(keyPath: \.code, array: ["Normal Value", "Trim", "TrimNewLine", "lowercase"]),
        "festival": TestData(keyPath: \.festival, array: ["Normal Value", "Trim", "TrimNewLine", "lowercase"]),
        "festival_id": TestData(keyPath: \.festivalId, array: ["Normal Value", "Trim", "TrimNewLine", "lowercase"]),
        "age_category": TestData(keyPath: \.ageCategory, array: ["3-6 yrs", nil, "11-15 yrs", nil]),
        "warnings": TestData(keyPath: \.warnings, array: ["Normal Value", nil, "TrimNewLine", nil]),
        "artist": TestData(keyPath: \.artist, array: ["Normal Value", nil, "TrimNewLine", nil]),
        "country": TestData(keyPath: \.country, array: ["Normal Value", nil, "TrimNewLine", nil]),
        "status": TestData(keyPath: \.status, array: [.active, .cancelled, .active, .deleted]),
        "website": TestData(keyPath: \.website, array: [URL(string: "https://www.othersite.org")!, URL(string: "https://www.google.com")!, URL(string: "http://someothersite.com")!, URL(string: "https://www.google.co.uk")!]),
        "url": TestData(keyPath: \.url, array: [URL(string: "https://www.othersite.org")!, URL(string: "https://www.google.com")!, URL(string: "http://someothersite.com")!, URL(string: "https://www.google.co.uk")!]),
        "genre_tags": TestData(keyPath: \.genreTags, array: ["Normal Value", nil, "TrimNewLine", nil]),
        "description": TestData(keyPath: \.description, array: ["<p> Magical things /> </p>", "<p>\n\t<strong>.</strong></h4>", "<p> Magical things</b></a> </p>", "<p>Created </p>"]),
        "description_teaser": TestData(keyPath: \.descriptionTeaser, array: [nil, "Some Text", nil, "Code for […]"]),
        "year": TestData(keyPath: \.year, array: [2024, 2024, 2024, 2024]),
        "disabled": TestData(keyPath: \.disabled, array: [
            FringeDisabled(otherServices: nil, audio: nil, captioningDates: nil, signedDates: nil, audioDates: nil),
            FringeDisabled(otherServices: false, audio: false, captioningDates: ["2024-08-25", "2024-08-25", "2024-08-26"], signedDates: ["2024-08-25", "2024-08-26"], audioDates: ["2024-08-25", "2024-08-26"]),
            FringeDisabled(otherServices: true, audio: true, captioningDates: ["2024-08-25"], signedDates: nil, audioDates: nil),
            nil]),
        "performance_space": TestData(keyPath: \.performanceSpace, array: [FringePerformanceSpace(name: "Test\nYes", ageLimited: nil, wheelchairAccess: true), FringePerformanceSpace(name: "Place", ageLimited: true, wheelchairAccess: false), FringePerformanceSpace(name: nil, ageLimited: false, wheelchairAccess: nil), FringePerformanceSpace(name: "Item", ageLimited: nil, wheelchairAccess: nil)]),
        "venue": TestData(keyPath: \.venue, array: [
            FringeVenue(code: "Code1", description: nil, name: "Name1", address: nil, position: FringeVenue.Position(lat: 55.964266, lon: -3.212126), postCode: "PostCode1", webAddress: nil, phone: nil, email: nil, disabledDescription: nil),
            FringeVenue(code: "Code2", description: "Desc2", name: "Name2", address: "Address2", position: FringeVenue.Position(lat: 123, lon: 4567), postCode: "Code2", webAddress: URL(string: "https://www.google.com")!, phone: "Phone2", email: "Email2", disabledDescription: "Disabled2"),
            FringeVenue(code: "Code3", description: nil, name: "Name3", address: nil, position: FringeVenue.Position(lat: 55.964266, lon: -3.212126), postCode: "PostCode3", webAddress: nil, phone: nil, email: nil, disabledDescription: nil),
            FringeVenue(code: "Code4", description: nil, name: "Name4", address: nil, position: FringeVenue.Position(lat: 55.97855, lon: -3.192044), postCode: "PostCode4", webAddress: nil, phone: nil, email: nil, disabledDescription: nil)
        ]),
        "updated": TestData(keyPath: \.updated, array: [
            DateComponents(calendar: Calendar.current, timeZone: fringeDateFormatter.timeZone, year: 2024, month: 9, day: 11, hour: 13, minute: 39, second: 35).date!,
            DateComponents(calendar: Calendar.current, timeZone: fringeDateFormatter.timeZone, year: 2024, month: 8, day: 14, hour: 9, minute: 39, second: 19).date!,
            DateComponents(calendar: Calendar.current, timeZone: fringeDateFormatter.timeZone, year: 2024, month: 9, day: 11, hour: 12, minute: 32, second: 38).date!,
            DateComponents(calendar: Calendar.current, timeZone: fringeDateFormatter.timeZone, year: 2024, month: 6, day: 12, hour: 12, minute: 40, second: 30).date!]),
        "images": TestData(keyPath: \.images, array: [
            [
                "31439a5845be59caf9d6caf502b2c123": FringeImage(hash: "31439a5845be59caf9d6caf502b2c123", orientation: .landscape, type: .thumb, versions: [
                    "original": FringeImage.Version(type: .original, width: 830, height: 550, mime: "image/png", url: URL(string: "https://www.google.com/img1.png")!),
                    "small-320": FringeImage.Version(type: .small320, width: 320, height: 212, mime: "image/jpeg", url: URL(string: "https://www.google.com/img2.jpg")!)
                ])
            ],
            [
                "1ddba093dc9ccea67755679060d8724d": FringeImage(hash: "1ddba093dc9ccea67755679060d8724d", orientation: .landscape, type: .thumb, versions: [
                    "original": FringeImage.Version(type: .original, width: 600, height: 400, mime: "image/jpeg", url: URL(string: "https://www.google.com/image")!)
                ])
            ],
            [
                "eec4ccb7002db1d74bf737087dfa1c4a": FringeImage(hash: "eec4ccb7002db1d74bf737087dfa1c4a", orientation: .landscape, type: .thumb, versions: [
                    "original": FringeImage.Version(type: .original, width: 830, height: 550, mime: "image/png", url: URL(string: "https://www.google.com/someotherimage.png")!)
                ])
            ],
            [
                "a3cc7b5ea9e6788a8a66b9c000e01eec": FringeImage(hash: "a3cc7b5ea9e6788a8a66b9c000e01eec", orientation: .landscape, type: .thumb, versions: [
                    "original": FringeImage.Version(type: .original, width: 2000, height: 1200, mime: "image/jpeg", url: URL(string: "https://www.site.com/imag.jpg")!)
                ])
            ]
        ]),
        "performances": TestData(keyPath: \.performances, array: [
            [
                FringePerformance(title: "SomeValue", type: .inPerson, isAtFixedTime: true, priceType: .free, price: 0, concession: nil, priceString: "Free", start: DateComponents(calendar: Calendar.current, timeZone: fringeDateFormatter.timeZone, year: 2024, month: 10, day: 27, hour: 12, minute: 15).date!, end: DateComponents(calendar: Calendar.current, timeZone: fringeDateFormatter.timeZone, year: 2024, month: 10, day: 27, hour: 12, minute: 35).date!, durationMinutes: 20, eventCode: "Normal Value"),
                FringePerformance(title: nil, type: .other("some other type"), isAtFixedTime: false, priceType: .other("some Price"), price: 32, concession: 0.4, priceString: "32 price", start: DateComponents(calendar: Calendar.current, timeZone: fringeDateFormatter.timeZone, year: 2024, month: 10, day: 27, hour: 12, minute: 45).date!, end: DateComponents(calendar: Calendar.current, timeZone: fringeDateFormatter.timeZone, year: 2024, month: 10, day: 27, hour: 13, minute: 05).date!, durationMinutes: 65, eventCode: "Normal Value")
            ],
            [
                FringePerformance(title: "SomeValue", type: .onlineLive, isAtFixedTime: true, priceType: .payWhatYouCan, price: 0, concession: nil, priceString: "Free", start: DateComponents(calendar: Calendar.current, timeZone: fringeDateFormatter.timeZone, year: 2024, month: 10, day: 27, hour: 12, minute: 15).date!, end: DateComponents(calendar: Calendar.current, timeZone: fringeDateFormatter.timeZone, year: 2024, month: 10, day: 27, hour: 12, minute: 35).date!, durationMinutes: 20, eventCode: "Trim")
            ],
            [],
            []
        ]),
        "fringe_first": nil,
        "longitude": nil,
        "latitude": nil,
        "artist_type": nil,
        "performers_number": nil,
        "non_english": nil,
        "twitter": nil,
        "sub_venue": nil,
        "update_times": nil,
        "discounts": nil,
        "related_content": nil,
        "categories": nil
    ]
}

// MARK: - Support

// Note: Set as `@unchecked` as KeyPaths "should" be fine, plus this is only in the testing target
extension KeyPath: @retroactive @unchecked Sendable {}
