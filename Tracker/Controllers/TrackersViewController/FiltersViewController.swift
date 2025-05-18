//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 16/05/2025.
//

import UIKit
//TODO: Прятать кнопку фильтры если нету трекеров
protocol FiltersViewControllerDelegate: AnyObject {
    func filtersViewController(didSelectFilter filter: TrackerFilter)
}

final class FiltersViewController: UIViewController {
    weak var delegate: FiltersViewControllerDelegate?
    
    var selectedFilter: TrackerFilter = .allFilters
    private var selectedIndex: Int {
        filters.firstIndex(of: selectedFilter) ?? 0
    }
    
    private let filters: [TrackerFilter] = [
        .allFilters,
        .trackersForToday,
        .completedTrackers,
        .uncompletedTrackers
    ]
    
    private let titles = [
        NSLocalizedString("allTrackers", comment: ""),
        NSLocalizedString("trackersForToday", comment: ""),
        NSLocalizedString("completedTrackers", comment: ""),
        NSLocalizedString("notCompletedTrackers", comment: "")
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filtersTitle", comment: "")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 75
        tableView.layoutMargins = .init(top: 26, left: 16, bottom: 26, right: 16)
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            
            tableView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 3),
            tableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = titles[indexPath.row]
        cell.textLabel?.textColor = .black
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.backgroundColor = .tBackground
        cell.selectionStyle = .none
        cell.accessoryType = (indexPath.row == selectedIndex) ? .checkmark : .none
        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let selectedFilter = filters[indexPath.row]
        delegate?.filtersViewController(didSelectFilter: selectedFilter)
        
        tableView.visibleCells.forEach { $0.accessoryType = .none }
        cell.accessoryType = .checkmark
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == titles.count - 1 {
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
}

//@available(iOS 17.0, *)
//#Preview {
//    FiltersViewController()
//}
