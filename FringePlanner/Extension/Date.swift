//
//  Date.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 23/01/2025.
//

import Foundation

extension Date {
    /// Returns the date set to the nearest second
    func resetToSecond() -> Date {
        let timeInterval = floor(self.timeIntervalSinceReferenceDate)
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }
    
    /// Returns a formatted string representing the time range, respecting the user's locale settings.
    ///  - Example output: "12/31/2024, 10:30 AM - 11:45 AM" or "31/12/2024, 10:30 - 11:45"
    ///  depending on the locale.
    static func formattedTimeRange(start: Date, end: Date, locale: Locale = .current) -> String {
        // If the start date is after the end date, then we don't have a valid time range
        guard start <= end else { return "Unknown Time" }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none // We only want the date part here
        dateFormatter.locale = locale
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none // We only want the time part here
        timeFormatter.timeStyle = .short
        timeFormatter.locale = locale
        
        let dateString = dateFormatter.string(from: start)
        let startTimeString = timeFormatter.string(from: start)
        let endTimeString = timeFormatter.string(from: end)

        return "\(dateString) \(startTimeString) - \(endTimeString)"
    }
}
