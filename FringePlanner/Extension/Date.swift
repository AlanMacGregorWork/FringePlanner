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
}
