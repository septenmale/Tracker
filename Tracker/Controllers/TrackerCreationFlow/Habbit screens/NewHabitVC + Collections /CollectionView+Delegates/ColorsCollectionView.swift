//
//  ColorsCollectionView.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 26/01/2025.
//

import UIKit

final class ColorsCollectionView: UICollectionView {
    weak var changeButtonStateDelegate: ChangeButtonStateDelegate?
    
    let colorsCollectionViewItems = TrackerColors.colors
    var selectedColor: UIColor? {
        didSet {
            reloadData()
        }
    }
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        self.delegate = self
        self.dataSource = self
        self.isScrollEnabled = false
        self.allowsMultipleSelection = false
        
        self.register(ColorsCollectionCell.self, forCellWithReuseIdentifier: ColorsCollectionCell.reuseIdentifier)
        self.register(ColorsCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ColorsCollectionHeader.reuseIdentifier)
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorsCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colorsCollectionViewItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionCell.reuseIdentifier, for: indexPath) as? ColorsCollectionCell
        guard let cell else { return UICollectionViewCell() }
        
        let color = colorsCollectionViewItems[indexPath.item]
        cell.colorLabel.backgroundColor = color
        
        if color == selectedColor {
            cell.layer.borderWidth = 3
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            cell.layer.borderColor = colorsCollectionViewItems[indexPath.item].withAlphaComponent(0.3).cgColor
        } else {
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            assertionFailure("Unexpected element kind: \(kind)")
            return UICollectionReusableView()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ColorsCollectionHeader.reuseIdentifier,
            for: indexPath
        ) as? ColorsCollectionHeader else {
            assertionFailure("Failed to dequeue ColorsCollectionHeader")
            return UICollectionReusableView()
        }
        
        headerView.titleLabel.text = NSLocalizedString("colorTitle", comment: "")
        return headerView
        
    }
}

extension ColorsCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionCell else { return }
        
        selectedCell.layer.borderWidth = 3
        selectedCell.layer.cornerRadius = 8
        selectedCell.layer.masksToBounds = true
        selectedCell.layer.borderColor = colorsCollectionViewItems[indexPath.item].withAlphaComponent(0.3).cgColor
        
        selectedColor = colorsCollectionViewItems[indexPath.item]
        changeButtonStateDelegate?.changeCreateButtonState()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionCell else { return }
        
        selectedCell.layer.borderWidth = 0
        
    }
}

extension ColorsCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
}
