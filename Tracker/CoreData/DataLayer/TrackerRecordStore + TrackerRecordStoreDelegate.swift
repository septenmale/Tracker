//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 05/02/2025.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    
    weak var delegate: TrackerRecordStoreDelegate?
    private let context: NSManagedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    convenience override init() {
        let context = CoreDataManager.shared.context
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
        
        CoreDataManager.shared.saveContext()
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
            CoreDataManager.shared.saveContext()
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
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Уведомляем делегата, что данные обновились (например, чтобы обновить UI)
        delegate?.didUpdateRecords()
    }
    
}
