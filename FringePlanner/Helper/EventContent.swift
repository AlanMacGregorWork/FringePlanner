//
//  EventContent.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 26/04/2025.
//

import Foundation
import SwiftData

/// Represents the possible states of event content
enum EventContent {
    /// No event was found matching the provided event code
    case noEventFound
    /// Event was successfully found and retrieved from the database
    case eventFound(DBFringeEvent)
    /// An error occurred while attempting to retrieve the event from the database
    case databaseError(DBError)

    /// Creates a new event details content state by fetching an event with the provided code
    /// - Parameters:
    ///   - eventCode: The unique identifier code for the event to retrieve
    ///   - modelContainer: The model container for database access
    init(eventCode: String, modelContainer: ModelContainer) {
        let context = ModelContext(modelContainer)
        let eventPredicate = #Predicate<DBFringeEvent> { $0.code == eventCode }
        let events: [DBFringeEvent]
        do {
            events = try DBHelper.getDBModels(from: eventPredicate, context: context)
        } catch {
            self = .databaseError(error)
            return
        }
        guard let firstEvent = events.first else {
            fringeAssertFailure("No event found for expected event code: \(eventCode)")
            self = .noEventFound
            return
        }
        self = .eventFound(firstEvent)
    }
}
