//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Viktor on 25/12/2024.
//

import UIKit

final class StatisticViewController: UIViewController {
    let viewModel: TrackersViewModel
    private let statCard = StatisticCardView()
    
    private lazy var stubStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stubImageView, stubLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let stubImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .stubIfNoStatistics)
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let stubLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = NSLocalizedString("noStatisticsLabel", comment: "")
        return label
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .tGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let statValue = String(viewModel.getCompletedTrackersAmount())
        let statText = String.localizedStringWithFormat(
            NSLocalizedString("numberOfTrackers", comment: ""),
            viewModel.getCompletedTrackersAmount()
        )
        
        statCard.setValue(statValue, text: statText)
        manageStubView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("statisticLabel", comment: "")
        
        setupUI()
    }
    
    private func manageStubView() {
        let numberOfRecords = viewModel.getCompletedTrackersAmount()
        stubStackView.isHidden = numberOfRecords > 0
        statCard.isHidden = numberOfRecords == 0
    }
    
    private func setupUI() {
        statCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubStackView)
        view.addSubview(statCard)
        view.addSubview(separatorLine)
        
        
        NSLayoutConstraint.activate([
            statCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            statCard.heightAnchor.constraint(equalToConstant: 90),
            
            stubStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            separatorLine.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
