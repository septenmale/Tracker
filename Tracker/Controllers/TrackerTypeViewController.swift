//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 11/01/2025.
//

import UIKit

final class TrackerTypeViewController: UIViewController {
    
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
    
    lazy private var habbitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(switchToHabbitController), for: .touchUpInside)
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
    //TODO: Add switchToHabbitController logic
    @objc private func switchToHabbitController() {
        let newHabitViewController = NewHabitViewController()
        present(newHabitViewController, animated: true)
    }
    //TODO: Add switchToEventController logic
    @objc private func switchToEventController() {
        let newEventViewController = NewEventViewController()
        present(newEventViewController, animated: true)
    }
    
    private func setupStackView() {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(habbitButton)
        stackView.addArrangedSubview(eventButton)
    }
    
    private func setupConstraints() {
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38),
            
            habbitButton.heightAnchor.constraint(equalToConstant: 60),
            habbitButton.widthAnchor.constraint(equalToConstant: 335),
            
            eventButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.widthAnchor.constraint(equalToConstant: 335),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
}
