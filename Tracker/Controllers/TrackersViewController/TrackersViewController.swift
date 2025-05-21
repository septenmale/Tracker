//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Viktor on 25/12/2024.
//

import UIKit

final class TrackersViewController: UIViewController, TrackersViewModelDelegate {
    private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    private var currentFilter: TrackerFilter = .allFilters
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("trackersLabel", comment: "")
        viewModel.delegate = self
        
        addNavItems()
        setUpCollectionView()
        setupConstraints()
        
        updateTrackers(for: selectedDate, filter: currentFilter)
        viewModel.checkPinCategoryExists()
    }
    
    let viewModel: TrackersViewModel
    let categoryViewModel = TrackerCategoryViewModel(model: TrackerCategoryStore.shared)
    
    // Возможно сделать computed и получать с VM через viewModel.getTrackers чтобы не хранить тут
    var filteredTrackers: [TrackerCategory] = []
    
    let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .label
        searchController.searchBar.placeholder = NSLocalizedString("searchControllerText", comment: "")
        return searchController
    }()
    
    private let stubLabel: UIImageView = {
        let label = UIImageView()
        label.image = UIImage(named: "StubIfNoTrackers")
        return label
    }()
    
    private let stubLabelText: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("mainScreenPlaceHolder", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(stubLabel)
        stackView.addArrangedSubview(stubLabelText)
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    //TODO: Попробовать изменить randering mode на alwaysTemplate у картинки. И добавить новую в assets/добавить динамический цвет в assets
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AddNewTrackerButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(addTracker), for: .touchUpInside)
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .tGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .tBlue
        button.setTitle(NSLocalizedString("filtersTitle", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.titleEdgeInsets = UIEdgeInsets(top: 20, left: 14, bottom: 20, right: 14)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filtersButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didUpdateTrackers() {
        updateTrackers(for: selectedDate, filter: currentFilter)
    }
    
    @objc
    private func filtersButtonDidTap() {
        let filtersViewController = FiltersViewController()
        filtersViewController.delegate = self
        filtersViewController.selectedFilter = currentFilter
        present(filtersViewController, animated: true)
    }
    
    @objc private func addTracker() {
        let trackerTypeViewController = TrackerTypeViewController(viewModel: self.viewModel)
        trackerTypeViewController.newTrackerDelegate = self
        present(trackerTypeViewController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let chosenDate = sender.date
        selectedDate = Calendar.current.startOfDay(for: chosenDate)
        
        if currentFilter == .trackersForToday {
            currentFilter = .allFilters
        }
        
        updateTrackers(for: selectedDate, filter: currentFilter)
    }
    
    private func updateTrackers(for date: Date, filter: TrackerFilter) {
        filteredTrackers = viewModel.getTrackers(for: date, filter: filter)
        collectionView.reloadData()
        setupUIBasedOnData()
    }
    
    private func addNavItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController
    }
    
    private func setupConstraints() {
        view.addSubview(filtersButton)
        view.addSubview(stackView)
        view.addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubLabel.widthAnchor.constraint(equalToConstant: 80),
            stubLabel.heightAnchor.constraint(equalToConstant: 80),
            
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            separatorLine.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: filtersButton.bottomAnchor, multiplier: 2),
        ])
    }
    
    private func setupUIBasedOnData() {
        let isEmpty = filteredTrackers.isEmpty
        updateScreen(showCollectionView: !isEmpty)
        if isEmpty && (currentFilter == .allFilters || currentFilter == .trackersForToday) {
            filtersButton.isHidden = true
        } else {
            filtersButton.isHidden = false
        }
    }
    
    private func updateScreen(showCollectionView: Bool) {
        collectionView.isHidden = !showCollectionView
        stackView.isHidden = showCollectionView
    }
    
    private func setUpCollectionView() {
        collectionView.isScrollEnabled = true
        collectionView.contentInset.bottom = 66
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(CollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeader.reuseIdentifier)
        collectionView.register(TrackersCell.self, forCellWithReuseIdentifier: TrackersCell.reuseIdentifier)
    }
    
}
// TODO: set up search logic
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension TrackersViewController: NewTrackerDelegate {
    func didCreateNewTracker() {
        updateTrackers(for: selectedDate, filter: currentFilter)
        setupUIBasedOnData()
    }
}

// MARK: - CollectionView Delegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        let indexPath = indexPaths[0]
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersCell else { return nil }
        
        return UIContextMenuConfiguration(
            previewProvider: {
                return cell.previewForContextMenu()
            },
            actionProvider: { actions in
                let category = self.filteredTrackers[indexPath.section].title
                let isPinned = (category == "pinned")
                let pinActionTitle = isPinned ? NSLocalizedString("unpinAction", comment: "") : NSLocalizedString("pinAction", comment: "")
                
                return UIMenu(children: [
                    UIAction(title: pinActionTitle) { _ in
                        let tracker = self.filteredTrackers[indexPath.section].items[indexPath.row]
                        if isPinned {
                            self.viewModel.unpinTracker(id: tracker.id)
                        } else {
                            self.viewModel.pinTracker(id: tracker.id)
                        }
                    },
                    UIAction(title: NSLocalizedString("editAction", comment: "")) { _ in
                        let tracker = self.filteredTrackers[indexPath.section].items[indexPath.row]
                        let categoryTitle = self.filteredTrackers[indexPath.section].title
                        let completedDays = self.viewModel.getDaysAmount(tracker)
                        
                        let editableData = EditableTrackerData(
                            tracker: tracker,
                            categoryTitle: categoryTitle,
                            completedDays: completedDays,
                        )
                        
                        let editVC = EditTrackerViewController(
                            data: editableData,
                            trackersViewModel: self.viewModel,
                            categoryViewModel: self.categoryViewModel
                        )
                        
                        self.present(editVC, animated: true)
                    },
                    // Возможно вынести алерту и дейтсвия в отдельный метод ?
                    UIAction(title: NSLocalizedString("deleteAction", comment: ""), attributes: .destructive) { _ in
                        let alert = UIAlertController(
                            title: NSLocalizedString("sureToDeleteTracker", comment: ""),
                            message: "",
                            preferredStyle: .actionSheet
                        )
                        
                        let deleteAction = UIAlertAction(title: NSLocalizedString("deleteAction", comment: ""), style: .destructive) { [weak self] _ in
                            guard let self else { return }
                            
                            let tracker = self.filteredTrackers[indexPath.section].items[indexPath.item]
                            self.viewModel.removeTracker(by: tracker.id)
                        }
                        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelButtonTitle", comment: ""), style: .cancel)
                        
                        alert.addAction(deleteAction)
                        alert.addAction(cancelAction)
                        
                        self.present(alert, animated: true)
                    },
                ])
            })
    }
}

// MARK: - CollectionView DataSource
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
        let selectedDate = Calendar.current.startOfDay(for: datePicker.date)
        let currentDate = Calendar.current.startOfDay(for: Date())
        
        let isCompleted = viewModel.isTrackerCompleted(tracker, on: selectedDate)
        let daysCount = viewModel.getDaysAmount(tracker)
        
        let category = self.filteredTrackers[indexPath.section].title
        let isPinned = (category == "pinned")
        
        cell.trackerId = tracker.id
        cell.isPinned = isPinned
        cell.updateUI(isCompleted: isCompleted, daysCount: daysCount, tracker: tracker)
        
        cell.changeStateClosure = { [weak self] trackerId in
            guard let self else { return }
            guard let tracker = self.viewModel.verifyTracker(by: trackerId) else { return }
            
            let selectedDate = Calendar.current.startOfDay(for: datePicker.date)
            guard selectedDate <= currentDate else { return }
            
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            assertionFailure("Unexpected element kind \(kind)")
            return UICollectionReusableView()
        }
        
        guard  let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CollectionHeader.reuseIdentifier,
            for: indexPath
        ) as? CollectionHeader else {
            assertionFailure("Failed to dequeue ColorsCollectionHeader")
            return UICollectionReusableView()
        }
        
        if filteredTrackers[indexPath.section].title == "pinned" {
            headerView.titleLabel.text = NSLocalizedString("pinnedCategory", comment: "")
        } else {
            headerView.titleLabel.text = filteredTrackers[indexPath.section].title
        }
        
        return headerView
    }
}

// MARK: - CollectionView FlowLayoutDelegate
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

extension TrackersViewController: FiltersViewControllerDelegate {
    func filtersViewController(didSelectFilter filter: TrackerFilter) {
        currentFilter = filter
        
        if filter == .trackersForToday {
            let today = Calendar.current.startOfDay(for: Date())
            selectedDate = today
            datePicker.setDate(today, animated: true)
        }
        
        updateTrackers(for: selectedDate, filter: currentFilter)
    }
}
