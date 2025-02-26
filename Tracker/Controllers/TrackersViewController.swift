//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Viktor on 25/12/2024.
//

import UIKit

final class TrackersViewController: UIViewController, TrackersViewModelDelegate {
    
    private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Trackers"
        viewModel.delegate = self
        
        addNavItems()
        setupStackView()
        setUpCollectionView()
        setupConstraints()
        
        updateTrackers(for: selectedDate)
        setupUIBasedOnData()
    }
    
    let viewModel = TrackersViewModel()
    var filteredTrackers: [TrackerCategory] = [] //TODO: Move to VM
    
    let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
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
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    func didUpdateTrackers() {
        print("📢 (didUpdateTrackers) Трекеры обновлены, обновляем UI!")
        updateTrackers(for: selectedDate)
        setupUIBasedOnData()
    }
    
    @objc private func addTracker() {
        let trackerTypeViewController = TrackerTypeViewController(viewModel: self.viewModel)
        trackerTypeViewController.newTrackerDelegate = self
        present(trackerTypeViewController, animated: true)
    }
    // TODO: add picked date logic
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let chosenDate = sender.date
        // Обновляем выбранную дату
        selectedDate = Calendar.current.startOfDay(for: chosenDate)
        print("📅 DatePicker изменён: \(sender.date) -> \(selectedDate)")
        updateTrackers(for: selectedDate)
    }
    
    private func updateTrackers(for date: Date) {
        print("🔄 updateTrackers() вызван для даты: \(date)")
        filteredTrackers = viewModel.getTrackers(for: date)
        print("📂 После вызова getTrackers, количество: \(filteredTrackers.count)")
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
    
    private func setupUIBasedOnData() {
        filteredTrackers.isEmpty ? updateScreen(showCollectionView: false) : updateScreen(showCollectionView: true)
    }
    
    private func updateScreen(showCollectionView: Bool) {
        collectionView.isHidden = !showCollectionView
        stackView.isHidden = showCollectionView
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
        
        collectionView.register(CollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeader.reuseIdentifier)
        collectionView.register(TrackersCell.self, forCellWithReuseIdentifier: TrackersCell.reuseIdentifier)
    }
    
}
// TODO: set up filtration logic
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension TrackersViewController: NewTrackerDelegate {
    func didCreateNewTracker() {
        updateTrackers(for: Date())
        setupUIBasedOnData()
    }
}
