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
}
