//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 05/02/2025.
//

import CoreData
import UIKit

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    
    weak var delegate: TrackerRecordStoreDelegate?
    private let context: NSManagedObjectContext
    
    // NSFetchedResultsController для работы с TrackerRecordCoreData
    lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        // Сортировка по дате
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        // Изначально предикат может быть nil – будем обновлять через метод updateFetchRequest(for:)
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    // Конструкторы
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        do {
            try fetchedResultsController.performFetch()
            print("✅ FRC успешно загружен при инициализации!")
        } catch {
            print("❌ Ошибка загрузки FRC: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Обновление выборки по дате
    
    /// Обновляет предикат выборки FRC для выбранной даты
    func updateFetchRequest(for date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = NSPredicate(format: "date == %@", startOfDay as NSDate)
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
            print("✅ FRC обновлен для даты: \(startOfDay)")
        } catch {
            print("❌ Ошибка обновления FRC: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Методы для добавления и удаления записей
    
    /// Добавляет новую запись для трекера
    func addRecord(_ record: TrackerRecord) {
        // Создаем новую запись TrackerRecordCoreData
        let recordToBeSaved = TrackerRecordCoreData(context: context)
        recordToBeSaved.id = UUID()  // Или record.id, если требуется сохранять оригинальный id
        recordToBeSaved.date = Calendar.current.startOfDay(for: record.date)
        
        // Находим соответствующий TrackerCoreData по record.id
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)
        
        do {
            if let tracker = try context.fetch(fetchRequest).first {
                // Устанавливаем связь (так как связь теперь "to one")
                recordToBeSaved.trackers = tracker
            } else {
                print("⚠️ Не найден трекер с id \(record.id)")
            }
        } catch {
            print("❌ Ошибка при поиске трекера: \(error.localizedDescription)")
        }
        
        saveContext()
    }
    
    /// Удаляет запись для трекера по id и дате
    func deleteRecord(id trackerID: UUID, date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        // Используем tracker's id для поиска записи
        fetchRequest.predicate = NSPredicate(format: "trackers.id == %@ AND date == %@", trackerID as CVarArg, startOfDay as NSDate)
        
        do {
            let recordsToDelete = try context.fetch(fetchRequest)
            recordsToDelete.forEach { context.delete($0) }
            saveContext()
        } catch {
            print("❌ Ошибка удаления записи: \(error.localizedDescription)")
        }
    }
    
    func getDaysAmount(for trackerID: UUID) -> Int {
            let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "trackers.id == %@", trackerID as CVarArg)
            do {
                let records = try context.fetch(fetchRequest)
                return records.count
            } catch {
                print("❌ Ошибка получения количества дней для трекера: \(error.localizedDescription)")
                return 0
            }
        }
    
    // MARK: - Сохранение контекста
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                print("❌ Ошибка сохранения в Core Data: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Уведомляем делегата, что данные обновились (например, чтобы обновить UI)
        delegate?.didUpdateRecords()
    }
}
