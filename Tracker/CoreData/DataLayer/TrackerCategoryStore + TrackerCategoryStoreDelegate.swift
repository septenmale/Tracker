//
//  TrackerStore.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 05/02/2025.
//

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
        let context = CoreDataManager.shared.context
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
    
    func addCategory(_ category: TrackerCategory) {
        
        let categoryToBeSaved = TrackerCategoryCoreData(context: context)
        categoryToBeSaved.title = category.title
        categoryToBeSaved.trackers = NSSet()
        
        CoreDataManager.shared.saveContext()
        
    }
    
}
