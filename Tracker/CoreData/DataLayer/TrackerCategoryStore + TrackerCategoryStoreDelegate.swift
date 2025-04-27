//
//  TrackerStore.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 05/02/2025.
//

import CoreData
// Должна быть связана с ViewModel
final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    //TODO: Добавить FRC чтобы связать Model и ViewModel
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
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { coreDataDevice in
                guard let title = coreDataDevice.title else { return nil }
                return TrackerCategory(title: title, items: [])
            }
        } catch {
            assertionFailure("Failed to add device: \(error.localizedDescription)")
            return []
        }
    }
    
}
