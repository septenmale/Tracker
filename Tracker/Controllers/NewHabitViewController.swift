//
//  Untitled.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 12/01/2025.
//

import UIKit

final class NewHabitViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupStackView()
        setupTableView()
        setupConstraints()
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    private var items = [
        ("Категория", ""),
        ("Расписание", "")
    ]
    
    private var selectedDays: [Int] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Новая привычка"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .tBackground
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .tGray
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createNewEvent), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.tRed, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.tRed.cgColor
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backToTrackerTypeVC), for: .touchUpInside)
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func updateScheduleSubtitle(_ selectedDays: [Int]) {
        let weekdaysShort = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        
        if selectedDays.count == weekdaysShort.count {
            items[1].1 = "каждый день"
        } else {
            var sortedDays = [String]()
            for day in selectedDays.sorted() {
                sortedDays.append(weekdaysShort[day])
            }
            let dayNames = sortedDays.joined(separator: ", ")
            items[1].1 = dayNames
        }
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = false
        tableView.clipsToBounds = true
        tableView.backgroundColor = .tBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupStackView() {
        view.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
    }
    
    private func setupConstraints() {
        
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38),
            
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 161),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
        
    }
    
    @objc private  func createNewEvent() {
        
    }
    
    @objc private func backToTrackerTypeVC() {
        
    }
    
}

extension NewHabitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableHeight = tableView.bounds.height
        return tableHeight / CGFloat(items.count)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == items.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets.zero
        }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.selectedWeekdays = selectedDays
            
            scheduleVC.onDaysSelected = { [weak self] days in
                self?.selectedDays = days
                self?.updateScheduleSubtitle(days)
            }
            
            present(scheduleVC, animated: true)
        }
    }
    
}

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let (title, subtitle) = items[indexPath.row]
        
        cell.textLabel?.text = title
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        cell.detailTextLabel?.text = subtitle
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .tGray
        
        cell.backgroundColor = .tBackground
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.layer.masksToBounds = false
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
}
