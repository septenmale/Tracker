//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 16/01/2025.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupConstraints()
    }
    
    var onDaysSelected: (([Int]) -> Void)?
    
    private let weekdays = [
        NSLocalizedString("monday", comment: ""), NSLocalizedString("tuesday", comment: ""), NSLocalizedString("wednesday", comment: ""), NSLocalizedString("thursday", comment: ""), NSLocalizedString("friday", comment: ""), NSLocalizedString("saturday", comment: ""), NSLocalizedString("sunday", comment: "")
    ]
    
    var selectedWeekdays: [Int] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("schedule", comment: "")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("confirmButtonTitle", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .blackDay
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.layoutMargins = .init(top: 26, left: 16, bottom: 26, right: 16)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = false
        tableView.clipsToBounds = true
        tableView.backgroundColor = .tBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    @objc private func submitButtonTapped() {
        onDaysSelected?(selectedWeekdays)
        dismiss(animated: true)
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            selectedWeekdays.append(sender.tag)
        } else {
            selectedWeekdays.removeAll { $0 == sender.tag }
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        view.addSubview(titleLabel)
        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38),
            
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -47),
            
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 60),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            
        ])
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let switchControl = UISwitch()
        
        switchControl.tag = indexPath.row
        switchControl.isOn = selectedWeekdays.contains(indexPath.row)
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        cell.textLabel?.text = weekdays[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        cell.backgroundColor = .tBackground
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.layer.masksToBounds = false
        cell.selectionStyle = .none
        cell.accessoryView = switchControl
        
        return cell
    }
    
    
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableHeight = tableView.bounds.height
        return tableHeight / CGFloat(weekdays.count)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == weekdays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        }
    }
    
}
