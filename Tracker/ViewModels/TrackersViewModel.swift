//
//  TrackersVIewModel.swift
//  Tracker
//
//  Created by Viktor on 30/12/2024.
//

import Foundation
import UIKit

final class TrackersViewModel {
    
    private var completedTrackers: [TrackerRecord] = []
    var categories: [TrackerCategory] = [TrackerCategory(
        title: "По умолчанию",
        items: [])
    ]
    
    func markTrackerAsCompleted(_ tracker: Tracker, on date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        let newRecord = TrackerRecord(id: tracker.id, date: startOfDay)
        
        completedTrackers = completedTrackers + [newRecord]
    }
    
    func markTrackerAsInProgress(_ tracker: Tracker, on date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        completedTrackers.removeAll { $0.id == tracker.id && $0.date == startOfDay }
    }
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return completedTrackers.contains(where: { $0.id == tracker.id && $0.date == startOfDay })
    }
    
    func getDaysAmount(_ tracker: Tracker) -> Int {
        return completedTrackers.filter { $0.id == tracker.id }.count
    }
    
    func verifyTracker(by id: UUID) -> Tracker? {
        for category in categories {
            if let tracker = category.items.first(where: { $0.id == id }) {
                return tracker
            }
        }
        return nil
    }
    
    func addTracker(title: String, schedule: [Int], emoji: String, color: UIColor) {
        
        let weekdays: [Weekday] = schedule.compactMap { index in
            switch index {
            case 0: return .monday
            case 1: return .tuesday
            case 2: return .wednesday
            case 3: return .thursday
            case 4: return .friday
            case 5: return .saturday
            case 6: return .sunday
            default: return nil
            }
        }
        
        let newTracker = Tracker(
            id: UUID(),
            title: title,
            color: color,
            emoji: emoji,
            schedule: weekdays
        )
        
        let defaultCategory = categories[0]
        let updatedCategory = TrackerCategory(
            title: defaultCategory.title,
            items: defaultCategory.items + [newTracker]
        )
        
        categories = [updatedCategory]
        
    }
    
    func getTrackers(for date: Date) -> [TrackerCategory] {
        var filteredCategories: [TrackerCategory] = []
        
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let currentWeekday = weekdayFromIndex(weekdayIndex)
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        for category in categories {
            let filteredItems = category.items.filter { tracker in
                if tracker.schedule.isEmpty {
                    return !completedTrackers.contains { $0.id == tracker.id } ||
                    completedTrackers.contains { $0.id == tracker.id && $0.date == startOfDay }
                } else {
                    return tracker.schedule.contains(currentWeekday)
                }
            }
            
            if !filteredItems.isEmpty {
                filteredCategories.append(TrackerCategory(title: category.title, items: filteredItems))
            }
        }
        
        return filteredCategories
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
