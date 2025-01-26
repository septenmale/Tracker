//
//  EmojiCollectionCell.swift
//  Tracker
//
//  Created by Viktor on 24/01/2025.
//

import UIKit

final class EmojiCollectionCell: UICollectionViewCell {
    
    static let reuseIdentifier = "EmojiCollectionCell"
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.heightAnchor.constraint(equalToConstant: 38),
            emojiLabel.widthAnchor.constraint(equalToConstant: 38),
            
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 9),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -11),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
