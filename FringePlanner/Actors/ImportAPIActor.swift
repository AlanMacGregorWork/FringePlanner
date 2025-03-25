//
//  ImportAPIActor.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 25/01/2025.
//

import SwiftData
import Foundation

@ModelActor
/// Allows the importing of API models into the database
actor ImportAPIActor {
    /// The main entry point for updating the database from the fringe events
    func updateEvents(_ events: [FringeEvent]) throws(DBError) -> [DBHelper.Status] {
        let statuses = try events.map(update(event:)).flatMap({ $0 })
        try DBHelper.saveChanges(modelContext: modelContext)
        return statuses
    }
    
    // MARK: Private Functions
    
    /// Updates/Adds a single fringe event into the database
    private func update(event: FringeEvent) throws(DBError) -> [DBHelper.Status] {
        let venueStatus = try DBHelper.updateModel(from: event.venue, modelContext: modelContext)
        let eventStatus = try DBHelper.updateModel(from: event, modelContext: modelContext)
        var performanceInputStatuses: [DBHelper.Status] = []
        for performance in event.performances {
            let status = try DBHelper.updateModel(from: performance, modelContext: modelContext)
            performanceInputStatuses.append(status)
        }
        let performanceCancelledStatuses = try cancelMissingPerformances(from: event)
        // Return statuses
        return [venueStatus, eventStatus] + performanceInputStatuses + performanceCancelledStatuses
    }
    
    /// Cancels any performances no longer included in the event
    private func cancelMissingPerformances(from event: FringeEvent) throws(DBError) -> [DBHelper.Status] {
        let predicate = newlyCancelledPerformancesPredicate(from: event)
        let cancelledPerformances = try DBHelper.getDBModels(from: predicate, context: modelContext)
        return cancelledPerformances.map({ performance in
            performance.updateStatusToCancelled()
            return DBHelper.Status.updatedModel(type: DBFringePerformance.self, referenceID: performance.referenceID)
        })
    }
    
    // MARK: Predicates
    
    /// Predicate to find performances that are no longer active
    private func newlyCancelledPerformancesPredicate(from event: FringeEvent) -> Predicate<DBFringePerformance> {
        let eventCode = event.code
        let performanceStartDates = event.performances.map(\.start)
        let activePredicate = DBFringePerformance.predicate(for: .active)
        
        return #Predicate<DBFringePerformance> { dbPerformance in
            // The performance must be for this event
            dbPerformance.eventCode == eventCode &&
            // The performance must not be included in the input performances
            !performanceStartDates.contains(dbPerformance.start) &&
            // The performance must previously have previously been active
            activePredicate.evaluate(dbPerformance)
        }
    }
}
