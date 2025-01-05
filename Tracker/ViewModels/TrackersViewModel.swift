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
    
    init() {
        
            let tracker1 = Tracker(
                id: UUID(),
                title: "Сделать зарядку",
                color: "blue",
                emoji: "💪",
                schedule: [.monday, .wednesday, .friday]
            )
            
            let tracker2 = Tracker(
                id: UUID(),
                title: "Читать книгу",
                color: "green",
                emoji: "📖",
                schedule: [.tuesday, .thursday, .saturday]
            )
            
            let category = TrackerCategory(title: "Здоровье", items: [tracker1, tracker2])
            categories = [category]
        }
    
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
    
    func getTrackers(for date: Date) -> [Tracker] {
        var result: [Tracker] = []
        
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let currentWeekday = weekdayFromIndex(weekdayIndex)
        
        for category in categories {
            for tracker in category.items {
                if tracker.schedule.contains(currentWeekday) {
                    result.append(tracker)
                }
            }
        }
        return result
    }
    
    private func weekdayFromIndex(_ index: Int) -> Weekday {
        switch index {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
    
}
