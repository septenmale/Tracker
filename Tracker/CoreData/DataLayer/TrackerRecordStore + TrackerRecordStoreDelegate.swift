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
        try? fetchedResultsController.performFetch()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
    
    func fetchRecords() -> [TrackerRecord] {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return [] }
        
        return fetchedObjects.compactMap { coreDataObject in
            guard let id = coreDataObject.id,
                  let date = coreDataObject.date
            else { return nil }
            
            return TrackerRecord(id: id, date: date)
        }
    }
    
    func addRecord(_ record: TrackerRecord) {
        let recordToBeSaved = TrackerRecordCoreData(context: context)
        recordToBeSaved.id = record.id
        recordToBeSaved.date = record.date
        
        saveContext()
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
