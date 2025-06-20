//
//  TrackersVIewModel.swift
//  Tracker
//
//  Created by Viktor on 30/12/2024.
//

import UIKit

protocol TrackersViewModelDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackersViewModel {
    weak var delegate: TrackersViewModelDelegate?
    
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    private let categoryStore = TrackerCategoryStore.shared
    
    init() {
        trackerStore.delegate = self
    }
    
    func getTrackers(for date: Date, filter: TrackerFilter?) -> [TrackerCategory] {
        switch filter {
        case .allFilters:
            return filteredCategories(for: date)
            
        case .trackersForToday:
            let today = Calendar.current.startOfDay(for: Date())
            return filteredCategories(for: today)
            
        case .completedTrackers:
            return isCompletedCategories(for: date, isCompleted: true)
            
        case .uncompletedTrackers:
            return isCompletedCategories(for: date, isCompleted: false)
            
        case .none:
            return filteredCategories(for: date)
        }
        
    }
    
    private func isCompletedCategories(for date: Date, isCompleted: Bool) -> [TrackerCategory] {
        recordStore.updateFetchRequest(for: date)
        guard let recordsForDate = recordStore.fetchedResultsController.fetchedObjects else {
            assertionFailure("⚠️ getTrackers: Нет записей для даты \(date)")
            return []
        }
        let completedIDsForDate = recordsForDate.compactMap { $0.trackers?.id }
        let allCategories = categoryStore.fetchAllCategories()
        let dayOfWeek = weekdayFromDate(date)
        
        let filteredCategories: [TrackerCategory] = allCategories.compactMap { category in
            let filteredTrackers = category.items.filter { tracker in
                if tracker.schedule.isEmpty {
                    // Одноразовый трекер (без расписания)
                    let totalCompletionCount = recordStore.getDaysAmount(for: tracker.id)
                    let isCompletedToday = completedIDsForDate.contains(tracker.id)
                    if isCompleted {
                        // Показываем как завершённый только если был выполнен сегодня (разовый)
                        return isCompletedToday
                    } else {
                        // Показываем как невыполненный, если НИКОГДА не был выполнен
                        return totalCompletionCount == 0
                    }
                } else {
                    // Привычка с расписанием: сравниваем статус на текущий день
                    if isCompleted {
                        // Показываем как завершённый, если был выполнен сегодня и должен быть сегодня
                        return completedIDsForDate.contains(tracker.id) && tracker.schedule.contains(dayOfWeek)
                    } else {
                        // Показываем как невыполненный, если НЕ выполнен сегодня, но должен быть сегодня
                        return !completedIDsForDate.contains(tracker.id) && tracker.schedule.contains(dayOfWeek)
                    }
                }
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, items: filteredTrackers)
        }
        
        let pinnedKey = "pinned"
        let sortedCategories = filteredCategories.sorted { first, second in
            if first.title == pinnedKey && second.title != pinnedKey {
                return true
            } else if first.title != pinnedKey && second.title == pinnedKey {
                return false
            } else {
                return true
            }
        }
        return sortedCategories
    }
    
    private func filteredCategories(for date: Date) -> [TrackerCategory] {
        recordStore.updateFetchRequest(for: date)
        guard let recordsForDate = recordStore.fetchedResultsController.fetchedObjects else {
            assertionFailure("⚠️ getTrackers: Нет записей для даты \(date)")
            return []
        }
        let completedIDsForDate = recordsForDate.compactMap { $0.trackers?.id }
        let allCategories = categoryStore.fetchAllCategories()
        let dayOfWeek = weekdayFromDate(date)
        
        let filteredCategories: [TrackerCategory] = allCategories.compactMap { category in
            let visibleTrackers = category.items.filter { tracker in
                if tracker.schedule.isEmpty {
                    let totalCompletionCount = recordStore.getDaysAmount(for: tracker.id)
                    let isCompletedToday = completedIDsForDate.contains(tracker.id)
                    return totalCompletionCount == 0 ? true : isCompletedToday
                } else {
                    return tracker.schedule.contains(dayOfWeek)
                }
            }
            return visibleTrackers.isEmpty ? nil : TrackerCategory(title: category.title, items: visibleTrackers)
        }
        
        let pinnedKey = "pinned"
        let sortedCategories = filteredCategories.sorted { first, second in
            if first.title == pinnedKey && second.title != pinnedKey {
                return true
            } else if first.title != pinnedKey && second.title == pinnedKey {
                return false
            } else {
                return true
            }
        }
        return sortedCategories
    }
    
    func updateTracker(
        id: UUID,
        title: String,
        emoji: String,
        color: UIColor,
        schedule: [Int],
        category: String
    ) {
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
        
        trackerStore.updateTracker(
            id: id,
            title: title,
            emoji: emoji,
            color: color,
            schedule: weekdays,
            categoryTitle: category
        )
        delegate?.didUpdateTrackers()
    }
    
    private func weekdayFromDate(_ date: Date) -> Weekday {
        let idx = Calendar.current.component(.weekday, from: date)
        switch idx {
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
    
    func markTrackerAsCompleted(_ tracker: Tracker, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        let newRecord = TrackerRecord(id: tracker.id, date: day)
        recordStore.addRecord(newRecord)
        DispatchQueue.main.async {
            self.delegate?.didUpdateTrackers()
        }
    }
    
    func markTrackerAsInProgress(_ tracker: Tracker, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        recordStore.deleteRecord(id: tracker.id, date: day)
        DispatchQueue.main.async {
            self.delegate?.didUpdateTrackers()
        }
    }
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        recordStore.updateFetchRequest(for: date)
        guard let records = recordStore.fetchedResultsController.fetchedObjects else {
            return false
        }
        
        return records.contains { $0.trackers?.id == tracker.id }
    }
    // Возможно стоит воспользоваться методом "weekdayFromData"
    func addTracker(title: String, schedule: [Int], emoji: String, color: UIColor, category: String) {
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
        let newTracker = Tracker(id: UUID(), title: title, color: color, emoji: emoji, schedule: weekdays)
        trackerStore.addTracker(newTracker, category)
    }
    
    func getDaysAmount(_ tracker: Tracker) -> Int {
        return recordStore.getDaysAmount(for: tracker.id)
    }
    
    func verifyTracker(by id: UUID) -> Tracker? {
        return trackerStore.fetchTrackers().first { $0.id == id }
    }
    
    func removeTracker(by id: UUID) {
        trackerStore.deleteTracker(withId: id)
    }
    
    func checkPinCategoryExists() {
        categoryStore.ensurePinCategoryExists()
    }
    
    func pinTracker(id: UUID) {
        trackerStore.pinTracker(id: id)
    }
    
    func unpinTracker(id: UUID) {
        trackerStore.unpinTracker(id: id)
    }
    
    func getCompletedTrackersAmount() -> Int {
        let allRecords = recordStore.getAllRecords()
        return allRecords.count
    }
}

extension TrackersViewModel: TrackerStoreDelegate {
    func didUpdateTrackers() {
        delegate?.didUpdateTrackers()
    }
}
