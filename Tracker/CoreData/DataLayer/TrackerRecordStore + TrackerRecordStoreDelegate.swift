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
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        return frc
    }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        do {
               try fetchedResultsController.performFetch()
               print("✅ (init) NSFetchedResultsController загружен успешно!")
           } catch {
               print("❌ (init) Ошибка загрузки FRC: \(error.localizedDescription)")
           }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
    
    func fetchRecords() -> [TrackerRecord] {
        print("🔎 fetchRecords() вызван")

        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            print("📜 fetchRecords(): FRC не загрузил объекты, возвращаем пустой массив.")
            return []
        }

        return fetchedObjects.compactMap { coreDataObject in
            guard let date = coreDataObject.date,
                  let tracker = (coreDataObject.trackers as? Set<TrackerCoreData>)?.first
            else {
                print("⚠️ fetchRecords(): Ошибка! Одна из записей в Core Data имеет nil значения.")
                return nil
            }

            print("✅ fetchRecords(): Загружена запись -> Tracker ID: \(tracker.id ?? UUID()), Дата: \(date)")
            return TrackerRecord(id: tracker.id ?? UUID(), date: date)
        }
    }
    
    func addRecord(_ record: TrackerRecord) {
        let recordToBeSaved = TrackerRecordCoreData(context: context)

        recordToBeSaved.id = UUID()
        recordToBeSaved.date = record.date

        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)

        do {
            if let existingTracker = try context.fetch(fetchRequest).first {
                recordToBeSaved.trackers = NSSet(object: existingTracker)
            } else {
                print("⚠️ Ошибка: Не найден трекер с id \(record.id)")
            }
        } catch {
            print("❌ Ошибка при поиске трекера: \(error.localizedDescription)")
        }

        saveContext()
    }
    
    func deleteRecord(id: UUID, date: Date) {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", id as CVarArg, date as CVarArg)

        do {
            let recordsToDelete = try context.fetch(fetchRequest)
            recordsToDelete.forEach { context.delete($0) }
            saveContext()
        } catch {
            print("❌ Ошибка удаления записи: \(error)")
        }
    }
    
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
    
}
