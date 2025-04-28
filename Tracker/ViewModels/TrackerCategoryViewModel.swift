//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 26/04/2025.
//

import Foundation

typealias Binding<T> = (T) -> Void

final class TrackerCategoryViewModel {
    var didChangeContent: Binding<Void>?
    private let model: TrackerCategoryStore
    
    init(model: TrackerCategoryStore) {
        self.model = model
        model.delegate = self
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

//MARK: - TrackerCategoryStore Delegate
extension TrackerCategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        didChangeContent?(())
    }
}
