//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Viktor on 25/12/2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Trackers"
        
        addNavItems()
        setupStackView()
        setUpCollectionView()
        setupConstraints()
        
        updateTrackers(for: Date())
    }
    
    private let viewModel = TrackersViewModel()
    private var filteredTrackers: [Tracker] = []
    
    private let emojis = [ "🍇", "🍈", "🍉", "🍊", "🍋" ]
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        return searchController
    }()
    
    private let stubLabel: UIImageView = {
        let label = UIImageView()
        label.image = UIImage(named: "StubIfNoTrackers")
        return label
    }()
    
    private let stubLabelText: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
   lazy private var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AddNewTrackerButton"), for: .normal)
        button.addTarget(self, action: #selector(addTracker), for: .touchUpInside)
        return button
    }()
    
    lazy private var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    // TODO: add button logic
    @objc private func addTracker() {
        
    }
    // TODO: add picked date logic
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
       let selectedDate = sender.date
        updateTrackers(for: selectedDate)
    }
    
    private func updateTrackers(for date: Date) {
        filteredTrackers = viewModel.getTrackers(for: date)
        collectionView.reloadData()
    }
    
    private func addNavItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(stubLabel)
        stackView.addArrangedSubview(stubLabelText)
    }
    
    private func setupConstraints() {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubLabel.widthAnchor.constraint(equalToConstant: 80),
            stubLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setUpCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackersCell.self, forCellWithReuseIdentifier: TrackersCell.reuseIdentifier)
    }
    
}
// TODO: set up filtration logic
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCell.reuseIdentifier, for: indexPath) as? TrackersCell
        guard let cell else { return UICollectionViewCell() }
        
        let tracker = filteredTrackers[indexPath.row]
        cell.titleLabel.text = tracker.title
        return cell
    }
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
}
