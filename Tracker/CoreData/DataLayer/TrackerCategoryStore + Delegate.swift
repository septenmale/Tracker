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

final class TrackerCategoryStore: NSObject {
    static let shared = TrackerCategoryStore()
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        _ = fetchedResultsController
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            assertionFailure("Failed to initialize FRC: \(error.localizedDescription)")
        }
        return frc
    }()
    
    func saveCategory(_ category: TrackerCategory) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.title = category.title
                
                try context.save()
            } else {
                return
            }
        } catch {
            assertionFailure("Failed to add device: \(error.localizedDescription)")
        }
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        guard let fetchedCategories = fetchedResultsController.fetchedObjects else { return [] }
        
        let categoriesSwift: [TrackerCategory] = fetchedCategories.compactMap { coreDataCategory in
            guard let categoryTitle = coreDataCategory.title else {
                assertionFailure("⚠️ fetchAllCategories: Пропущена категория без названия")
                return nil
            }
            let trackersCoreData = (coreDataCategory.trackers as? Set<TrackerCoreData> ?? []).sorted {
                ($0.title ?? "") < ($1.title ?? "")
            }
            
            let trackersSwift: [Tracker] = trackersCoreData.compactMap { coreDataTracker in
                guard let id = coreDataTracker.id,
                      let trackerTitle = coreDataTracker.title,
                      let color = coreDataTracker.color,
                      let emoji = coreDataTracker.emoji
                else {
                    assertionFailure("⚠️ fetchAllCategories: \(categoryTitle) Пропущена категория из-за отсутствия обязательных данных")
                    return nil
                }
                
                let scheduleData = coreDataTracker.schedule ?? Data()
                let schedule = (try? JSONDecoder().decode([Weekday].self, from: scheduleData)) ?? []
                
                return Tracker(id: id, title: trackerTitle, color: color, emoji: emoji, schedule: schedule)
            }
            
            return TrackerCategory(title: categoryTitle, items: trackersSwift)
        }
        
        return categoriesSwift
    }
}

//MARK: - FetchResultsController Delegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
