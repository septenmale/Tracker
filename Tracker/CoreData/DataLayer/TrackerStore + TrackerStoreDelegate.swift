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
        delegate?.didUpdateTrackers()
    }
    
    func fetchTrackers() -> [Tracker] {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
              print("❌ (fetchTrackers) Ошибка: нет объектов в FRC!")
              return []
          }
        print("🛠 (fetchTrackers) Загружено трекеров из Core Data: \(fetchedObjects.count)")
        return fetchedObjects.compactMap { coreDataObject in
            guard let id = coreDataObject.id,
                  let title = coreDataObject.title,
                  let color = coreDataObject.color,
                  let emoji = coreDataObject.emoji,
                  let scheduleData = coreDataObject.schedule as? Data,
                  let schedule = try? JSONDecoder().decode([Weekday].self, from: scheduleData)
            else {
                print("⚠️ (fetchTrackers) Пропущен трекер из-за ошибки декодирования")
                return nil
            }
            print("🛠 (fetchTrackers) Итоговое количество трекеров: \(fetchedObjects.count)")
            return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
        }
    }
    
    func addTracker(_ tracker: Tracker) {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "title == %@", "По умолчанию")

        do {
            let fetchedCategories = try context.fetch(fetchRequest)

            let category: TrackerCategoryCoreData
            if let existingCategory = fetchedCategories.first {
                category = existingCategory
            } else {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.title = "По умолчанию"
                category = newCategory
            }

            let trackerToBeSaved = TrackerCoreData(context: context)
            trackerToBeSaved.id = tracker.id
            trackerToBeSaved.title = tracker.title
            trackerToBeSaved.color = tracker.color
            trackerToBeSaved.emoji = tracker.emoji
            trackerToBeSaved.schedule = try? JSONEncoder().encode(tracker.schedule) // ✅ Исправили тип данных
            
            trackerToBeSaved.category = category // ✅ Привязываем категорию

            print("🛠 Добавляем трекер '\(tracker.title)' в категорию '\(category.title ?? "Неизвестно")'")
            
            category.trackers = (category.trackers as? Set<TrackerCoreData> ?? []).union([trackerToBeSaved]) as NSSet
            
            saveContext()
            print("✅ Трекер '\(tracker.title)' успешно сохранён!")

        } catch {
            print("❌ Ошибка при добавлении трекера: \(error.localizedDescription)")
        }
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
