//
//  TrackersCell.swift
//  Tracker
//
//  Created by Viktor on 05/01/2025.
//

import UIKit

final class TrackersCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackersCell"
    
    private let trackerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Color selection 5")
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let emodjiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = "😀"
        return label
    }()
    
    let titleLabel: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lable.text = "Sabaka"
        lable.textColor = .white
        return lable
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    let daysAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "1 день"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    let addAsCompleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "Color selection 5")
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContainerView()
        setupStackView()
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStackView() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(daysAmountLabel)
        stackView.addArrangedSubview(addAsCompleteButton)
    }
    
    private func setupContainerView() {
        contentView.addSubview(trackerContainerView)
        trackerContainerView.addSubview(emodjiLabel)
        trackerContainerView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        
        emodjiLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        trackerContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            trackerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerContainerView.heightAnchor.constraint(equalToConstant: 90),
            
            emodjiLabel.topAnchor.constraint(equalTo: trackerContainerView.topAnchor, constant: 12),
            emodjiLabel.leadingAnchor.constraint(equalTo: trackerContainerView.leadingAnchor, constant: 12),
            emodjiLabel.heightAnchor.constraint(equalToConstant: 24),
            emodjiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: emodjiLabel.bottomAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: trackerContainerView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: trackerContainerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trackerContainerView.trailingAnchor, constant: -12),
            
            addAsCompleteButton.widthAnchor.constraint(equalToConstant: 34),
            addAsCompleteButton.heightAnchor.constraint(equalToConstant: 34),
            
            stackView.topAnchor.constraint(equalTo: trackerContainerView.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
}

