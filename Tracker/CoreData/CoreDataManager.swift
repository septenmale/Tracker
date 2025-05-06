//
//  DataBaseStore.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 09/03/2025.
//

import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ModelsCoreData")
        
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                assertionFailure("❌ Ошибка сохранения в Core Data: \(error.localizedDescription)")
            }
        }
    }
    
}
