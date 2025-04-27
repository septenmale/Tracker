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
    
    //Добавить метод для загрузки всех категорий
}
