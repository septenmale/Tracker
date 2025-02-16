//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 05/02/2025.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    
    weak var trackerStoreDelegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
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
        trackerStoreDelegate?.didUpdateTrackers()
    }
    
    func fetchTrackers() -> [Tracker] {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return [] }
        return fetchedObjects.compactMap { coreDataObject in
            guard let id = coreDataObject.id,
                  let title = coreDataObject.title,
                  let color = coreDataObject.color,
                  let emoji = coreDataObject.emoji,
                  let scheduleData = coreDataObject.schedule as? Data,
                  let schedule = try? JSONDecoder().decode([Weekday].self, from: scheduleData)
            else { return nil }
            
            return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
        }
    }
    
    func addTracker(_ tracker: Tracker) {
        let trackerToBeSaved = TrackerCoreData(context: context)
        trackerToBeSaved.id = tracker.id
        trackerToBeSaved.title = tracker.title
        trackerToBeSaved.color = tracker.color
        trackerToBeSaved.emoji = tracker.emoji
        trackerToBeSaved.schedule = try? JSONEncoder().encode(tracker.schedule) as NSObject
        
        saveContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }
    
}
