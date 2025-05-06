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
        } catch {
            assertionFailure("❌ Ошибка загрузки FRC: \(error.localizedDescription)")
        }
    }
    
    /// Обновляет предикат выборки FRC для выбранной даты
    func updateFetchRequest(for date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = NSPredicate(format: "date == %@", startOfDay as NSDate)
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("❌ Ошибка обновления FRC: \(error.localizedDescription)")
        }
    }
    
    /// Добавляет новую запись для трекера
    func addRecord(_ record: TrackerRecord) {
        let recordToBeSaved = TrackerRecordCoreData(context: context)
        recordToBeSaved.id = UUID()
        recordToBeSaved.date = Calendar.current.startOfDay(for: record.date)
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)
        
        do {
            if let tracker = try context.fetch(fetchRequest).first {
                recordToBeSaved.trackers = tracker
            } else {
                assertionFailure("⚠️ addRecord: Не найден трекер с id \(record.id)")
            }
        } catch {
            assertionFailure("❌ Ошибка при поиске трекера: \(error.localizedDescription)")
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    /// Удаляет запись для трекера по id и дате
    func deleteRecord(id trackerID: UUID, date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "trackers.id == %@ AND date == %@", trackerID as CVarArg, startOfDay as NSDate)
        
        do {
            let recordsToDelete = try context.fetch(fetchRequest)
            recordsToDelete.forEach { context.delete($0) }
            CoreDataManager.shared.saveContext()
        } catch {
            assertionFailure("❌ Ошибка удаления записи: \(error.localizedDescription)")
        }
    }
    
    func getDaysAmount(for trackerID: UUID) -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackers.id == %@", trackerID as CVarArg)
        do {
            let records = try context.fetch(fetchRequest)
            return records.count
        } catch {
            assertionFailure("❌ Ошибка получения количества дней для трекера: \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}
