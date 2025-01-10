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
//        setupStackView()
        setUpCollectionView()
//        setupConstraints()
        
        updateTrackers(for: Date())
    }
    
    private let viewModel = TrackersViewModel()
    private var filteredTrackers: [TrackerCategory] = []
    
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
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
    
//    private let stubLabel: UIImageView = {
//        let label = UIImageView()
//        label.image = UIImage(named: "StubIfNoTrackers")
//        return label
//    }()
//    
//    private let stubLabelText: UILabel = {
//        let label = UILabel()
//        label.text = "Что будем отслеживать?"
//        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        return label
//    }()
    
//    private let stackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.spacing = 8
//        stackView.alignment = .center
//        return stackView
//    }()
    
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
        let selectedDate = Calendar.current.startOfDay(for: sender.date)
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
    
//    private func setupStackView() {
//        stackView.addArrangedSubview(stubLabel)
//        stackView.addArrangedSubview(stubLabelText)
//    }
    
//    private func setupConstraints() {
//        view.addSubview(stackView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            stubLabel.widthAnchor.constraint(equalToConstant: 80),
//            stubLabel.heightAnchor.constraint(equalToConstant: 80)
//        ])
//    }
    
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

extension TrackersViewController: UICollectionViewDelegate {
    
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTrackers[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCell.reuseIdentifier, for: indexPath) as? TrackersCell
        guard let cell else { return UICollectionViewCell() }
        
        let tracker = filteredTrackers[indexPath.section].items[indexPath.row]
        let selectedDate = datePicker.date
        
        let isCompleted = viewModel.isTrackerCompleted(tracker, on: selectedDate)
        let daysCount = viewModel.getDaysAmount(tracker)
        
        cell.trackerId = tracker.id
        cell.updateUI(isCompleted: isCompleted, daysCount: daysCount, tracker: tracker)
        
        cell.changeStateClosure = { [weak self] trackerId in
            guard let self else { return }
            guard let tracker = self.viewModel.getTracker(by: trackerId) else { return }

            let selectedDate = self.datePicker.date
            
            if self.viewModel.isTrackerCompleted(tracker, on: selectedDate) {
                    self.viewModel.markTrackerAsInProgress(tracker, on: selectedDate)
                } else {
                    self.viewModel.markTrackerAsCompleted(tracker, on: selectedDate)
                }
            
            let updatedIsCompleted = viewModel.isTrackerCompleted(tracker, on: selectedDate)
            let updatedDaysCount = self.viewModel.getDaysAmount(tracker)
            cell.updateUI(isCompleted: updatedIsCompleted, daysCount: updatedDaysCount, tracker: tracker)
        }
        
        return cell
    }
    //TODO: Refractor
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: CollectionHeader.reuseIdentifier,
                                                                             for: indexPath
            ) as! CollectionHeader
            
            headerView.titleLabel.text = filteredTrackers[indexPath.section].title
            return headerView
            
        default:
            fatalError("Unexpected supplementary element kind \(kind)")
        }
    }
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: params.leftInset, bottom: 10, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
}
