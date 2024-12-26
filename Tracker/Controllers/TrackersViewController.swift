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
        setupConstraints()
    }
    
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
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.text = DateFormatter.trackerVCDateFormatter.string(from: Date())
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AddNewTrackerButton"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        button.addTarget(self, action: #selector(addTracker), for: .touchUpInside)
        return button
    }()
    // TODO: add button logic
    @objc private func addTracker() {
        
    }
    
    private func addNavItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateLabel)
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
    
}
// TODO: set up filtration logic
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
}
