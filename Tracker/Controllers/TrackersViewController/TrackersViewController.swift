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
    }
    
    let viewModel = TrackersViewModel()
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
        updateTrackers(for: selectedDate)
    }
    
    @objc private func addTracker() {
        let trackerTypeViewController = TrackerTypeViewController(viewModel: self.viewModel)
        trackerTypeViewController.newTrackerDelegate = self
        present(trackerTypeViewController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let chosenDate = sender.date
        selectedDate = Calendar.current.startOfDay(for: chosenDate)
        updateTrackers(for: selectedDate)
    }
    
    private func updateTrackers(for date: Date) {
        filteredTrackers = viewModel.getTrackers(for: date)
        collectionView.reloadData()
        setupUIBasedOnData()
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
        updateTrackers(for: selectedDate)
        setupUIBasedOnData()
    }
}

// MARK: - CollectionView Delegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        let indexPath = indexPaths[0]
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersCell else { return nil }
        //TODO: Добавить локализацию
        return UIContextMenuConfiguration(
            previewProvider: {
                return cell.previewForContextMenu()
            },
            actionProvider: { actions in
                return UIMenu(children: [
                    UIAction(title: NSLocalizedString("pinAction", comment: "")) { _ in
                        // Тут вероятнее всего добавляем в категорию "закрепленные"
                        // Как добиться чтобы закрепленные были всегда с верху?
                    },
                    UIAction(title: NSLocalizedString("editAction", comment: "")) { _ in
                        
                    },
                    //TODO: Возможно вынести алерту и дейтсвия в отдельный метод ?
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
        
        cell.trackerId = tracker.id
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
        
        headerView.titleLabel.text = filteredTrackers[indexPath.section].title
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
