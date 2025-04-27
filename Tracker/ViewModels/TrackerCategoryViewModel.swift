//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 26/04/2025.
//

import Foundation

typealias Binding<T> = (T) -> Void

final class TrackerCategoryViewModel {
    private let model: TrackerCategoryStore
    
    init(model: TrackerCategoryStore) {
        self.model = model
    }
    
    func saveCategory(name: String) {
        let category = TrackerCategory(
            title: name,
            items: []
        )
        
        model.saveCategory(category)
    }
    
    func showAllTitles() -> [String] {
        let models = model.fetchAllCategories()
        return models.map { $0.title }
    }
}
