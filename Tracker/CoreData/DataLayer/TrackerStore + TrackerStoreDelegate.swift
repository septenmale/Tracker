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
                  let emoji = coreDataObject.emoji
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
    
    func deleteTracker(withId id: UUID) {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        
        do {
            guard let trackerToDelete = try context.fetch(fetchRequest).first else { return }
            context.delete(trackerToDelete)
            try context.save()
        } catch {
            assertionFailure("❌ deleteTracker: Ошибка при удалении трекера: \(error.localizedDescription)")
        }
    }
    
    func updateTracker(
        id: UUID,
        title: String,
        emoji: String,
        color: UIColor,
        schedule: [Weekday],
        categoryTitle: String
    ) {
        let trackerFetch: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerFetch.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let trackerToUpdate = try context.fetch(trackerFetch).first else {
                assertionFailure("❌ updateTracker: Трекер с таким id не найден")
                return
            }
            
            trackerToUpdate.title = title
            trackerToUpdate.emoji = emoji
            trackerToUpdate.color = color
            trackerToUpdate.schedule = try? JSONEncoder().encode(schedule)
            
            let categoryFetch: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            categoryFetch.predicate = NSPredicate(format: "title == %@", categoryTitle)
            
            let category: TrackerCategoryCoreData
            if let foundCategory = try context.fetch(categoryFetch).first {
                category = foundCategory
            } else {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.title = categoryTitle
                category = newCategory
            }
            trackerToUpdate.category = category
            
            try context.save()
        } catch {
            assertionFailure("❌ updateTracker: Ошибка при обновлении — \(error.localizedDescription)")
        }
    }
    
    func pinTracker(id: UUID) {
        let trackerFetch: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerFetch.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let tracker = try context.fetch(trackerFetch).first else {
                assertionFailure("❌ pinTracker: Трекер не найден")
                return
            }
            
            if tracker.category?.title == "pinned" {
                return
            }
            
            tracker.previousCategoryTitle = tracker.category?.title
            
            let categoryFetch: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            categoryFetch.predicate = NSPredicate(format: "title == %@", "pinned")
            let pinCategory: TrackerCategoryCoreData
            if let found = try context.fetch(categoryFetch).first {
                pinCategory = found
            } else {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.title = "pinned"
                pinCategory = newCategory
            }
            
            tracker.category = pinCategory
            
            try context.save()
        } catch {
            assertionFailure("❌ pinTracker: Ошибка — \(error.localizedDescription)")
        }
    }
    
    func unpinTracker(id: UUID) {
        let trackerFetch: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerFetch.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            guard let tracker = try context.fetch(trackerFetch).first else {
                assertionFailure("❌ unpinTracker: Трекер не найден")
                return
            }
            
            guard let prevTitle = tracker.previousCategoryTitle else {
                assertionFailure("❌ unpinTracker: Нет предыдущей категории")
                return
            }
            
            let categoryFetch: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            categoryFetch.predicate = NSPredicate(format: "title == %@", prevTitle)
            let prevCategory: TrackerCategoryCoreData
            if let found = try context.fetch(categoryFetch).first {
                prevCategory = found
            } else {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.title = prevTitle
                prevCategory = newCategory
            }
            
            tracker.category = prevCategory
            tracker.previousCategoryTitle = nil
            
            try context.save()
        } catch {
            assertionFailure("❌ unpinTracker: Ошибка — \(error.localizedDescription)")
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
