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
        try? fetchedResultsController.performFetch()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")

        do {
            let categoryCoreData = try context.fetch(fetchRequest)

            return categoryCoreData.compactMap { coreDataObject in
                let title = coreDataObject.title

                let trackersSet = (coreDataObject.trackers as? Set<TrackerCoreData>) ?? []

                let trackerModels: [Tracker] = trackersSet.compactMap { trackerCD in
                    guard let id = trackerCD.id,
                          let title = trackerCD.title,
                          let color = trackerCD.color,
                          let emoji = trackerCD.emoji,
                          let scheduleData = trackerCD.schedule as? Data,
                          let schedule = try? JSONDecoder().decode([Weekday].self, from: scheduleData)
                    else {
                        print("⚠️ Ошибка декодирования schedule для трекера: \(trackerCD.title ?? "Без названия")")
                        return nil
                    }

                    return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
                }
                
                return TrackerCategory(title: title, items: trackerModels)
            }
        } catch {
            print("❌ Ошибка загрузки категорий: \(error)")
            return []
        }
    }
    
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
