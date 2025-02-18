//
//  TrackerStore.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 05/02/2025.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
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
        delegate?.didUpdateCategories()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")

        do {
            let categoryCoreData = try context.fetch(fetchRequest)
            print("🛠 (fetchCategories) Загружено категорий из Core Data: \(categoryCoreData.count)")

            let categories = categoryCoreData.compactMap { coreDataObject in
                let title = coreDataObject.title ?? "По умолчанию"
                let trackersSet = (coreDataObject.trackers as? Set<TrackerCoreData>) ?? []
                
                print("🛠 (fetchCategories) Категория '\(title)', привязанных трекеров в Core Data: \(trackersSet.count)")

                let trackerModels: [Tracker] = trackersSet.compactMap { trackerCD in
                    guard let id = trackerCD.id,
                          let title = trackerCD.title,
                          let color = trackerCD.color,
                          let emoji = trackerCD.emoji else {
                        return nil
                    }

                    // ✅ Декодируем schedule из Data
                    let schedule: [Weekday]
                    if let scheduleData = trackerCD.schedule {
                        do {
                            schedule = try JSONDecoder().decode([Weekday].self, from: scheduleData)
                        } catch {
                            print("⚠️ Ошибка декодирования schedule у трекера ID: \(id) - \(error)")
                            schedule = []
                        }
                    } else {
                        schedule = []
                    }

                    print("✅ (fetchCategories) Трекер загружен: \(title), ID: \(id), Расписание: \(schedule)")
                    return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
                }

                return TrackerCategory(title: title, items: trackerModels)
            }

            return categories
        } catch {
            print("❌ Ошибка загрузки категорий: \(error)")
            return []
        }
    }
//        //TODO: ДОБАВЛ НЕДАВНО
//    func updateCategory(_ category: TrackerCategory) {
//        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
//        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
//
//        do {
//            let fetchedCategories = try context.fetch(fetchRequest)
//            
//            if let existingCategory = fetchedCategories.first {
//                // ✅ Удаляем старые связи (но не сами трекеры!)
//                existingCategory.trackers = NSSet() // 🔄 Вместо nil ставим пустой NSSet
//                
//                // ✅ Создаём NSSet только из уникальных трекеров
//                let newTrackers = category.items.compactMap { tracker in
//                    let fetchTrackerRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
//                    fetchTrackerRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
//
//                    if let existingTrackers = try? context.fetch(fetchTrackerRequest),
//                       let existingTracker = existingTrackers.first {
//                        return existingTracker // ✅ Используем уже существующий трекер
//                    } else {
//                        let trackerCoreData = TrackerCoreData(context: context)
//                        trackerCoreData.id = tracker.id
//                        trackerCoreData.title = tracker.title
//                        trackerCoreData.color = tracker.color
//                        trackerCoreData.emoji = tracker.emoji
//                        trackerCoreData.schedule = try? JSONEncoder().encode(tracker.schedule) as NSObject
//                        trackerCoreData.category = existingCategory // ✅ Устанавливаем категорию
//                        return trackerCoreData
//                    }
//                }
//                
//                existingCategory.trackers = NSSet(array: newTrackers)
//                
//                saveContext()
//                
//                // ✅ Исправляем ошибку с выводом количества трекеров
//                let trackersCount = (existingCategory.trackers as? Set<TrackerCoreData>)?.count ?? 0
//                print("✅ Категория '\(category.title)' обновлена! Трекеров: \(trackersCount)")
//                
//            } else {
//                print("⚠️ Категория '\(category.title)' не найдена для обновления.")
//            }
//        } catch {
//            print("❌ Ошибка при обновлении категории: \(error.localizedDescription)")
//        }
//    }
    
    func addCategory(_ category: TrackerCategory) {
        let categoryToBeSaved = TrackerCategoryCoreData(context: context)
        categoryToBeSaved.title = category.title
        categoryToBeSaved.trackers = NSSet()
        
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
