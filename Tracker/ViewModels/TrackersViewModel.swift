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
//TODO: category store перенести в новую VM
final class TrackersViewModel: TrackerStoreDelegate, TrackerCategoryStoreDelegate, TrackerRecordStoreDelegate {
    
    weak var delegate: TrackersViewModelDelegate?
    
    private let trackerStore = TrackerStore()
//    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    
    init() {
        trackerStore.delegate = self
//        categoryStore.delegate = self
        recordStore.delegate = self
    }
    
    // MARK: - Делегатные методы для обновления UI
    
    func didUpdateTrackers() {
        delegate?.didUpdateTrackers()
    }
    
    func didUpdateCategories() {
        delegate?.didUpdateTrackers()
    }
    
    func didUpdateRecords() {
        delegate?.didUpdateTrackers()
    }
    
    func getTrackers(for date: Date) -> [TrackerCategory] {
        // Обновляем выборку записей для выбранной даты
        recordStore.updateFetchRequest(for: date)
//        let startOfDay = Calendar.current.startOfDay(for: date)
        
        // Получаем записи (TrackerRecordCoreData) для выбранной даты
        guard let recordsForDate = recordStore.fetchedResultsController.fetchedObjects else {
            print("⚠️ Нет записей для даты \(date)")
            return []
        }
        
        // Собираем идентификаторы трекеров, которые отмечены именно на выбранную дату
        let completedIDsForDate = recordsForDate.compactMap { record in
            return record.trackers?.id
        }
        
        // Получаем все трекеры из хранилища
        let allTrackers = trackerStore.fetchTrackers()
        
        // Определяем день недели для выбранной даты (например, .monday, .tuesday, …)
        let dayOfWeek = weekdayFromDate(date)
        
        // Фильтруем трекеры по следующей логике:
        // Для нерегулярных событий (если schedule пустой):
        //   - Если событие никогда не отмечалось (общий счёт == 0), показываем его во все дни.
        //   - Если событие уже отмечалось, показываем его только, если оно отмечено на выбранную дату.
        // Для привычек (если schedule не пустой):
        //   - Показываем трекер только, если выбранный день содержится в его расписании.
        let filteredTrackers = allTrackers.filter { tracker in
            if tracker.schedule.isEmpty {
                let totalCompletionCount = recordStore.getDaysAmount(for: tracker.id)
                let isCompletedToday = completedIDsForDate.contains(tracker.id)
                if totalCompletionCount == 0 {
                    // Никогда не отмечался – показываем во все дни
                    return true
                } else {
                    // Уже отмечался – показываем только если сегодня отмечен
                    return isCompletedToday
                }
            } else {
                return tracker.schedule.contains(dayOfWeek)
            }
        }
        
        // Если после фильтрации нет трекеров, возвращаем пустой массив, чтобы UI показал заглушку
        if filteredTrackers.isEmpty {
            return []
        }
        
        let defaultCategory = TrackerCategory(title: "По умолчанию", items: filteredTrackers)
        return [defaultCategory]
    }
    
    // Вспомогательный метод для определения дня недели из даты
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
    
    // MARK: - Методы отметки выполнения трекера
    
    func markTrackerAsCompleted(_ tracker: Tracker, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        let newRecord = TrackerRecord(id: tracker.id, date: day)
        print("📝 Отмечаем '\(tracker.title)' выполненным на \(day)")
        recordStore.addRecord(newRecord)
        DispatchQueue.main.async {
            self.delegate?.didUpdateTrackers()
        }
    }
    
    func markTrackerAsInProgress(_ tracker: Tracker, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        print("🔄 Снимаем отметку с '\(tracker.title)' на \(day)")
        // Передаем идентификатор трекера, чтобы удалить запись, связанную с этим трекером на выбранную дату
        recordStore.deleteRecord(id: tracker.id, date: day)
        DispatchQueue.main.async {
            self.delegate?.didUpdateTrackers()
        }
    }
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        // Обновляем выборку для заданной даты
        recordStore.updateFetchRequest(for: date)
        // Получаем записи для выбранной даты
        guard let records = recordStore.fetchedResultsController.fetchedObjects else {
            return false
        }
        // Если хотя бы одна запись связана с данным трекером, считаем его выполненным
        return records.contains { $0.trackers?.id == tracker.id }
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
        let newTracker = Tracker(id: UUID(), title: title, color: color, emoji: emoji, schedule: weekdays)
        trackerStore.addTracker(newTracker)
    }
    
    // MARK: - Получение количества дней, когда трекер был выполнен
    //
    // Вся логика получения количества дней теперь инкапсулирована в TrackerRecordStore.
    func getDaysAmount(_ tracker: Tracker) -> Int {
        return recordStore.getDaysAmount(for: tracker.id)
    }
    
    // Дополнительный метод для проверки существования трекера по id
    func verifyTracker(by id: UUID) -> Tracker? {
        return trackerStore.fetchTrackers().first { $0.id == id }
    }
}
