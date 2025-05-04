//
//  TrackersVIewModel.swift
//  Tracker
//
//  Created by Viktor on 30/12/2024.
//

import UIKit
// Этот протокол для обновления UI в TrackerVC
protocol TrackersViewModelDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackersViewModel {
    
    weak var delegate: TrackersViewModelDelegate?
    
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    private let categoryStore = TrackerCategoryStore.shared
    //TODO: Тут обьединить получение всех категорий и трекером и приготовить готовый для отображение обьект.           Заменить получение trackerStore.fetchTrackers() на метод fetchAllCategories
    func getTrackers(for date: Date) -> [TrackerCategory] {
        // Обновляем выборку записей для выбранной даты
        recordStore.updateFetchRequest(for: date)
        
        // Получаем записи (TrackerRecordCoreData) для выбранной даты
        guard let recordsForDate = recordStore.fetchedResultsController.fetchedObjects else {
            print("⚠️ Нет записей для даты \(date)")
            return []
        }
        
        // Собираем идентификаторы трекеров, которые отмечены именно на выбранную дату
        let completedIDsForDate = recordsForDate.compactMap { record in
            return record.trackers?.id
        }
        
        let allCategories = categoryStore.fetchAllCategories()
        
        // Определяем день недели для выбранной даты (например, .monday, .tuesday, …)
        let dayOfWeek = weekdayFromDate(date)
        
        // Фильтруем трекеры по следующей логике:
        // Для нерегулярных событий (если schedule пустой):
        //   - Если событие никогда не отмечалось (общий счёт == 0), показываем его во все дни.
        //   - Если событие уже отмечалось, показываем его только, если оно отмечено на выбранную дату.
        // Для привычек (если schedule не пустой):
        //   - Показываем трекер только, если выбранный день содержится в его расписании.
        let filteredCategories: [TrackerCategory] = allCategories.compactMap { category in
            let visibleTrackers = category.items.filter { tracker in
                if tracker.schedule.isEmpty {
                    let totalCompletionCount = recordStore.getDaysAmount(for: tracker.id)
                    let isCompletedToday = completedIDsForDate.contains(tracker.id)
                    
                    if totalCompletionCount == 0 {
                        return true
                    } else {
                        return isCompletedToday
                    }
                } else {
                    return tracker.schedule.contains(dayOfWeek)
                }
            }
            
            return visibleTrackers.isEmpty ? nil : TrackerCategory(title: category.title, items: visibleTrackers)
        }
        
        return filteredCategories
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
    // Разобраться с "let weekdays"
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
    
    // MARK: - Получение количества дней, когда трекер был выполнен
    func getDaysAmount(_ tracker: Tracker) -> Int {
        return recordStore.getDaysAmount(for: tracker.id)
    }
    
    // Дополнительный метод для проверки существования трекера по id
    func verifyTracker(by id: UUID) -> Tracker? {
        return trackerStore.fetchTrackers().first { $0.id == id }
    }
}
