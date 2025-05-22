//
//  TrackersCell.swift
//  Tracker
//
//  Created by Viktor on 05/01/2025.
//

import UIKit

final class TrackersCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackersCell"
    
    var changeStateClosure: ((UUID) -> Void)?
    
    var trackerId: UUID?
    var isPinned: Bool = false
    
    private let trackerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Color selection 5")
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var topImagesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(emojiLabel)
        stackView.addArrangedSubview(pinImageView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .pinElement)
        imageView.isHidden = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let daysAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addAsCompleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .light, scale: .small)
        button.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
        button.tintColor = UIColor(named: "Color selection 5")
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(changeTrackerState), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    @objc private func changeTrackerState() {
        guard let trackerId else { return }
        changeStateClosure?(trackerId)
    }
    
    func previewForContextMenu() -> UIViewController {
        let previewController = UIViewController()
        previewController.view = trackerContainerView.snapshotView(afterScreenUpdates: true) ?? UIView()
        previewController.preferredContentSize = trackerContainerView.bounds.size
        return previewController
    }
    
    func updateUI(isCompleted: Bool, daysCount: Int, tracker: Tracker) {
        let buttonImage = isCompleted ? "checkmark.circle.fill" : "plus.circle.fill"
        addAsCompleteButton.setImage(UIImage(systemName: buttonImage), for: .normal)
        addAsCompleteButton.alpha = isCompleted ? 0.6 : 1
        daysAmountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: ""),
            daysCount
        )
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        trackerContainerView.backgroundColor = tracker.color
        addAsCompleteButton.tintColor = tracker.color
        pinImageView.isHidden = !isPinned
    }
    
    private func setupStackView() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(daysAmountLabel)
        stackView.addArrangedSubview(addAsCompleteButton)
    }
    
    private func setupContainerView() {
        contentView.addSubview(trackerContainerView)
        trackerContainerView.addSubview(topImagesStackView)
        trackerContainerView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        trackerContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerContainerView.heightAnchor.constraint(equalToConstant: 90),
            
            topImagesStackView.topAnchor.constraint(equalTo: trackerContainerView.topAnchor, constant: 12),
            topImagesStackView.leadingAnchor.constraint(equalTo: trackerContainerView.leadingAnchor, constant: 12),
            topImagesStackView.trailingAnchor.constraint(equalTo: trackerContainerView.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: topImagesStackView.bottomAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: trackerContainerView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: trackerContainerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trackerContainerView.trailingAnchor, constant: -12),
            
            addAsCompleteButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -12),
            addAsCompleteButton.widthAnchor.constraint(equalToConstant: 34),
            addAsCompleteButton.heightAnchor.constraint(equalToConstant: 34),
            addAsCompleteButton.widthAnchor.constraint(equalTo: addAsCompleteButton.heightAnchor),
            
            stackView.topAnchor.constraint(equalTo: trackerContainerView.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: trackerContainerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trackerContainerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            daysAmountLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 12)
        ])
    }
}
