//
//  EmojiCollectionViewDataSource.swift
//  Tracker
//
//  Created by Viktor on 24/01/2025.
//

import UIKit

extension NewHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojiCollectionViewItems.count
        } else if collectionView == colorsCollectionView {
            return colorsCollectionViewItems.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionCell.reuseIdentifier, for: indexPath) as? EmojiCollectionCell
            guard let cell else { return UICollectionViewCell() }
            
            cell.emojiLabel.text = emojiCollectionViewItems[indexPath.item]
            return cell } else if collectionView == colorsCollectionView {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionCell.reuseIdentifier, for: indexPath) as? ColorsCollectionCell
                guard let cell else { return UICollectionViewCell() }
                
                cell.colorLabel.backgroundColor = colorsCollectionViewItems[indexPath.item]
                return cell
            }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // TODO: Refactor
        if collectionView == emojiCollectionView {
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
        } else if collectionView == colorsCollectionView {
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                 withReuseIdentifier: ColorsCollectionHeader.reuseIdentifier,
                                                                                 for: indexPath
                ) as! ColorsCollectionHeader
                
                headerView.titleLabel.text = "Цвет"
                return headerView
                
            default:
                fatalError("Unexpected supplementary element kind \(kind)")
            }
        }
        return UICollectionReusableView()
    }
    
}
