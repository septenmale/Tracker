//
//  CollectionViewDataSource.swift
//  Tracker
//
//  Created by Viktor on 05/01/2025.
//

import UIKit

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTrackers[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCell.reuseIdentifier, for: indexPath) as? TrackersCell
        guard let cell else { return UICollectionViewCell() }
        
        let tracker = filteredTrackers[indexPath.section].items[indexPath.row]
        let selectedDate = Calendar.current.startOfDay(for: datePicker.date)
        let currentDate = Calendar.current.startOfDay(for: Date())
        
        let isCompleted = viewModel.isTrackerCompleted(tracker, on: selectedDate)
        let daysCount = viewModel.getDaysAmount(tracker)
        
        cell.trackerId = tracker.id
        cell.updateUI(isCompleted: isCompleted, daysCount: daysCount, tracker: tracker)
        
        cell.changeStateClosure = { [weak self] trackerId in
            guard let self else { return }
            guard let tracker = self.viewModel.verifyTracker(by: trackerId) else { return }

            let selectedDate = Calendar.current.startOfDay(for: datePicker.date)
            guard selectedDate <= currentDate else { return }
            
            if self.viewModel.isTrackerCompleted(tracker, on: selectedDate) {
                    self.viewModel.markTrackerAsInProgress(tracker, on: selectedDate)
                } else {
                    self.viewModel.markTrackerAsCompleted(tracker, on: selectedDate)
                }
            
            let updatedIsCompleted = viewModel.isTrackerCompleted(tracker, on: selectedDate)
            let updatedDaysCount = self.viewModel.getDaysAmount(tracker)
            cell.updateUI(isCompleted: updatedIsCompleted, daysCount: updatedDaysCount, tracker: tracker)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            assertionFailure("Unexpected element kind \(kind)")
            return UICollectionReusableView()
        }
        
        guard  let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CollectionHeader.reuseIdentifier,
            for: indexPath
        ) as? CollectionHeader else {
            assertionFailure("Failed to dequeue ColorsCollectionHeader")
            return UICollectionReusableView()
        }
        
        headerView.titleLabel.text = filteredTrackers[indexPath.section].title
        return headerView
        
    }
    
}
