//
//  TrackersVIewModel.swift
//  Tracker
//
//  Created by Viktor on 30/12/2024.
//

import Foundation

final class TrackersViewModel {
    
    private var completedTrackers: [TrackerRecord] = []
    private var categories: [TrackerCategory] = []
    
    func markTrackerAsCompleted(_ tracker: Tracker, on date: Date) {
        // create new record
        let newRecord = TrackerRecord(id: tracker.id, date: date)
        // adding to array immutable
        completedTrackers = completedTrackers + [newRecord]
    }
    
    func markTrackerAsInProgress(_ tracker: Tracker, on date: Date) {
        // creating new array without current record
        completedTrackers = completedTrackers.filter {
            !($0.id == tracker.id && $0.date == date)
        }
    }
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        return completedTrackers.contains(where: {
            $0.id == tracker.id && $0.date == date
        })
    }
    // add new Tracker
    func addTracker() {
        // TODO: adding logic
    }
    
}
