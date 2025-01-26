//
//  ColorsCollectionView.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 26/01/2025.
//

import UIKit

final class ColorsCollectionView: UICollectionView {
    
    let colorsCollectionViewItems: [UIColor] = [
        UIColor.collectionColor1,UIColor.collectionColor2,UIColor.collectionColor3,UIColor.collectionColor4,UIColor.collectionColor5,UIColor.collectionColor6,UIColor.collectionColor7,UIColor.collectionColor8,UIColor.collectionColor9,UIColor.collectionColor10,UIColor.collectionColor11,UIColor.collectionColor12,UIColor.collectionColor13,UIColor.collectionColor14,UIColor.collectionColor15,UIColor.collectionColor16,UIColor.collectionColor17,UIColor.collectionColor18
    ]
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        self.delegate = self
        self.dataSource = self
        self.isScrollEnabled = false
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
        return colorsCollectionViewItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionCell.reuseIdentifier, for: indexPath) as? ColorsCollectionCell
        guard let cell else { return UICollectionViewCell() }
        
        cell.colorLabel.backgroundColor = colorsCollectionViewItems[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // TODO: Refactor
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
