//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 11/01/2025.
//

import UIKit

final class TrackerTypeViewController: UIViewController {
    // Обьявить модель и привязать ее к вью модели
    private let categoryModel = TrackerCategoryStore.shared
    private lazy var categoryViewModel = TrackerCategoryViewModel(model: categoryModel)
    private lazy var categoryVC = CategoryViewController(viewModel: categoryViewModel)
    
    private let trackerViewModel: TrackersViewModel
    weak var newTrackerDelegate: NewTrackerDelegate?
    
    init(viewModel: TrackersViewModel) {
        self.trackerViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupStackView()
        setupConstraints()
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Создание трекера"
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    lazy private var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(switchToHabitController), for: .touchUpInside)
        return button
    }()
    
    lazy private var eventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(switchToEventController), for: .touchUpInside)
        return button
    }()
    
    @objc private func switchToHabitController() {
        let newHabitViewController = NewHabitViewController(viewModel: self.trackerViewModel, vc: categoryVC)
        newHabitViewController.newTrackerDelegate = newTrackerDelegate
        present(newHabitViewController, animated: true)
    }
    
    @objc private func switchToEventController() {
        let newEventViewController = NewEventViewController(viewModel: self.trackerViewModel, vc: categoryVC)
        newEventViewController.newTrackerDelegate = newTrackerDelegate
        present(newEventViewController, animated: true)
    }
    
    private func setupStackView() {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(habitButton)
        stackView.addArrangedSubview(eventButton)
    }
    
    private func setupConstraints() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.widthAnchor.constraint(equalToConstant: 335),
            
            eventButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.widthAnchor.constraint(equalToConstant: 335),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
