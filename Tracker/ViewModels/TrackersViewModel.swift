//
//  TrackersVIewModel.swift
//  Tracker
//
//  Created by Viktor on 30/12/2024.
//

import Foundation
import UIKit

protocol TrackersViewModelDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackersViewModel: TrackerStoreDelegate, TrackerCategoryStoreDelegate, TrackerRecordStoreDelegate {

    weak var delegate: TrackersViewModelDelegate?
    
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    
    init() {
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
    }
    
    func didUpdateTrackers() {
        print("📢 Трекеры обновились!")
        delegate?.didUpdateTrackers()
    }
    
    func didUpdateCategories() {
        print("📢 Категории обновились!")
        delegate?.didUpdateTrackers()
    }
    
    func didUpdateRecords() {
        print("📢 Записи о выполнении трекеров обновились!")
        delegate?.didUpdateTrackers()
    }
    
    func markTrackerAsCompleted(_ tracker: Tracker, on date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)

        let newRecord = TrackerRecord(id: tracker.id, date: startOfDay)
        print("📝 Добавляем запись о выполнении трекера: \(tracker.title), Дата: \(startOfDay)")

        recordStore.addRecord(newRecord)
        DispatchQueue.main.async {
                self.delegate?.didUpdateTrackers()
            }
        
    }
    
    func markTrackerAsInProgress(_ tracker: Tracker, on date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        recordStore.deleteRecord(id: tracker.id, date: startOfDay)
    }
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let allRecords = recordStore.fetchRecords()
        
        let completed = allRecords.contains { $0.id == tracker.id && $0.date == startOfDay }
        print("🔍 Проверяем выполнение трекера: \(tracker.title), Дата: \(startOfDay) -> Выполнен? \(completed)")
        
        return completed
    }
    
    func getDaysAmount(_ tracker: Tracker) -> Int {
        
        let allRecords = recordStore.fetchRecords()
        
        return allRecords.filter { $0.id == tracker.id }.count
    }
    
    func verifyTracker(by id: UUID) -> Tracker? {
        
        let allTrackers = trackerStore.fetchTrackers()
        
        return allTrackers.first { $0.id == id }
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

        // Добавляем сам трекер в БД
        trackerStore.addTracker(newTracker)
        
        print("✅ Трекер добавлен: \(newTracker.title)")
    }
    
    func getTrackers(for date: Date) -> [TrackerCategory] {
        print("🔎 getTrackers() вызван для даты: \(date)")
        
        let allCategories = categoryStore.fetchCategories()
        print("📂 Загружено категорий: \(allCategories.count)")
        
        let allRecords = recordStore.fetchRecords()
        print("📜 Всего записей о выполнении: \(allRecords.count)")
        
        let filteredCategories: [TrackerCategory] = allCategories.compactMap { category in
            let filteredItems = category.items.filter { tracker in
                
                let isCompletedToday = allRecords.contains { $0.date == date && $0.id == tracker.id }
                let hasRecord = allRecords.contains { $0.id == tracker.id }

                let isScheduled: Bool
                if tracker.schedule.isEmpty {
                    // Для нерегулярных трекеров
                    isScheduled = !hasRecord || isCompletedToday
                } else {
                    // Для регулярных трекеров
                    isScheduled = tracker.schedule.contains(weekdayFromIndex(Calendar.current.component(.weekday, from: date))) || isCompletedToday
                }

                print("🔍 Проверяем трекер: \(tracker.title)")
                print("   📆 Дата: \(date)")
                print("   ✅ Записан ли он как выполненный? \(isCompletedToday)")
                print("   📅 Должен ли отображаться? \(isScheduled)")

                return isScheduled
            }

            return filteredItems.isEmpty ? nil : TrackerCategory(title: category.title, items: filteredItems)
        }

        print("📂 Всего отфильтровано: \(filteredCategories.count)")
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
