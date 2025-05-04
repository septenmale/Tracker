//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 05/02/2025.
//

import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("❌TrackerStore init Ошибка загрузки FRC: \(error.localizedDescription)")
        }
    }
    
    convenience override init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    
    //TODO: Переделать FRC. Добавить performFetch, инициализировать в init
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
    
    func fetchTrackers() -> [Tracker] {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            assertionFailure("❌ (fetchTrackers) Ошибка: нет объектов в FRC!")
            return []
        }
        
        return fetchedObjects.compactMap { coreDataObject in
            guard let id = coreDataObject.id,
                  let title = coreDataObject.title,
                  let color = coreDataObject.color,
                  let emoji = coreDataObject.emoji,
                  let category = coreDataObject.category?.title
            else {
                assertionFailure("⚠️ (fetchTrackers) Пропущен трекер из-за отсутствия обязательных данных")
                return nil
            }
            
            let scheduleData = coreDataObject.schedule ?? Data()
            let schedule = (try? JSONDecoder().decode([Weekday].self, from: scheduleData)) ?? []
            
            return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
        }
    }
    
    func addTracker(_ tracker: Tracker, _ category: String) {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "title == %@", category)
        
        do {
            let fetchedCategories = try context.fetch(fetchRequest)
            
            let fetchedCategory: TrackerCategoryCoreData
            if let existingCategory = fetchedCategories.first {
                fetchedCategory = existingCategory
            } else {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.title = category
                fetchedCategory = newCategory
            }
            
            let trackerToBeSaved = TrackerCoreData(context: context)
            trackerToBeSaved.id = tracker.id
            trackerToBeSaved.title = tracker.title
            trackerToBeSaved.color = tracker.color
            trackerToBeSaved.emoji = tracker.emoji
            trackerToBeSaved.category = fetchedCategory
            trackerToBeSaved.schedule = try? JSONEncoder().encode(tracker.schedule)
            
            CoreDataManager.shared.saveContext()
            
        } catch {
            assertionFailure("❌ addTracker: Ошибка при добавлении трекера: \(error.localizedDescription)")
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
