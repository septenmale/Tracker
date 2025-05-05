//
//  ColorsCollectionCell.swift
//  Tracker
//
//  Created by Viktor on 25/01/2025.
//

import UIKit

final class ColorsCollectionCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ColorsCollectionCell"
    
    let colorLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(colorLabel)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            colorLabel.heightAnchor.constraint(equalToConstant: 40),
            colorLabel.widthAnchor.constraint(equalToConstant: 40)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
