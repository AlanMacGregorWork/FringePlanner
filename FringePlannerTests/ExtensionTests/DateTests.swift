//
//  DateTests.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 23/01/2025.
//

import Foundation
import Testing
@testable import FringePlanner

@Suite("Date Tests")
struct DateTests {
    @Test("Date reset to second")
    func testDateResetToSecond() throws {
        // Create a date with some microseconds (23 Jan 2025 21:51:00)
        let date = Date(timeIntervalSince1970: 1737672660.0005)
        // Reset the date to the nearest second
        let resetDate = date.resetToSecond()

        // Verify the dates are equal to themselves
        #expect(date == date, "Dates should be equal")
        #expect(resetDate == resetDate, "Dates should be equal")
        // Verify the dates are not equal as the microseconds are different
        #expect(date != resetDate, "Dates should not be equal")
        // Verify the microseconds have been reset from the original date
        let dateNanoseconds = try #require(Calendar.current.dateComponents([.nanosecond], from: date).nanosecond)
        let resetDateNanoseconds = try #require(Calendar.current.dateComponents([.nanosecond], from: resetDate).nanosecond)
        #expect(dateNanoseconds != 0, "Nanoseconds should not be 0")
        #expect(resetDateNanoseconds == 0, "Nanoseconds should be 0")
    }

    @Suite("Date formatted time range")
    struct DateFormattedTimeRangeTests {
        
        // swiftlint:disable identifier_name
        let date2005_06_03_18_31_00: Date
        let date2005_06_03_19_31_00: Date
        let date2005_06_03_09_15_00: Date
        let date2005_06_03_14_45_00: Date
        // swiftlint:enable identifier_name

        init() throws {
            date2005_06_03_18_31_00 = try #require(DateComponents(calendar: .current, year: 2025, month: 6, day: 3, hour: 18, minute: 31, second: 0).date)
            date2005_06_03_19_31_00 = try #require(DateComponents(calendar: .current, year: 2025, month: 6, day: 3, hour: 19, minute: 31, second: 0).date)
            date2005_06_03_09_15_00 = try #require(DateComponents(calendar: .current, year: 2025, month: 6, day: 3, hour: 9, minute: 15, second: 0).date)
            date2005_06_03_14_45_00 = try #require(DateComponents(calendar: .current, year: 2025, month: 6, day: 3, hour: 14, minute: 45, second: 0).date)
        }

        @Test("Changes based on locale")
        func testChangesBasedOnLocale() {
            let start = date2005_06_03_18_31_00
            let end = date2005_06_03_19_31_00

            // English GB
            let formattedRange = Date.formattedTimeRange(start: start, end: end, locale: Locale(identifier: "en_GB"))
            #expect(formattedRange == "03/06/2025 18:31 - 19:31")

            // English US
            let formattedRangeUS = Date.formattedTimeRange(start: start, end: end, locale: Locale(identifier: "en_US"))
            #expect(formattedRangeUS == "6/3/25 6:31 PM - 7:31 PM")
        }

        @Test("Handles invalid time range")
        func testHandlesInvalidTimeRange() {
            let start = date2005_06_03_19_31_00
            let end = date2005_06_03_18_31_00
            
            let formattedRange = Date.formattedTimeRange(start: start, end: end, locale: Locale(identifier: "en_GB"))
            #expect(formattedRange == "Unknown Time")
        }

        @Test("Handles time range with same start and end time")
        func testHandlesTimeRangeWithSameStartAndEndTime() {
            let date = date2005_06_03_18_31_00
            
            let formattedRange = Date.formattedTimeRange(start: date, end: date, locale: Locale(identifier: "en_GB"))
            #expect(formattedRange == "03/06/2025 18:31 - 18:31")
        }

        @Test("Handles morning and afternoon times")
        func testHandlesMorningAndAfternoonTimes() {
            // Morning time (9:15 AM) to afternoon time (2:45 PM)
            let morningTime = date2005_06_03_09_15_00
            let afternoonTime = date2005_06_03_14_45_00
            
            // Test with US locale (should show AM/PM)
            let formattedRangeUS = Date.formattedTimeRange(start: morningTime, end: afternoonTime, locale: Locale(identifier: "en_US"))
            #expect(formattedRangeUS == "6/3/25 9:15 AM - 2:45 PM")
            
            // Test with GB locale (typically uses 24-hour format)
            let formattedRangeGB = Date.formattedTimeRange(start: morningTime, end: afternoonTime, locale: Locale(identifier: "en_GB"))
            #expect(formattedRangeGB == "03/06/2025 09:15 - 14:45")
        }
    }
}
