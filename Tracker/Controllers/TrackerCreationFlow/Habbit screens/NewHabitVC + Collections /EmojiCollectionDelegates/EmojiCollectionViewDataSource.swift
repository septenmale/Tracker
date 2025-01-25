//
//  EmojiCollectionViewDataSource.swift
//  Tracker
//
//  Created by Viktor on 24/01/2025.
//

import UIKit

extension NewHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiCollectionViewItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionCell.reuseIdentifier, for: indexPath) as? EmojiCollectionCell
        guard let cell else { return UICollectionViewCell() }
        
        cell.emojiLabel.text = emojiCollectionViewItems[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // TODO: Refactor
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: EmojiCollectionHeader.reuseIdentifier,
                                                                             for: indexPath
            ) as! EmojiCollectionHeader
            
            headerView.titleLabel.text = "Emoji"
            return headerView
            
        default:
            fatalError("Unexpected supplementary element kind \(kind)")
        }
        
    }
    
}
