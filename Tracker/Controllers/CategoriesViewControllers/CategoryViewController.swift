//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 25/04/2025.
//

import UIKit
// Эта вью связана с VM и обновляет таблицу
final class CategoryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private let viewModel: TrackerCategoryViewModel
    
    init(viewModel: TrackerCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let items = ["Продукты", "Домашнее хранение", "Транспорт", "Здоровье", "Другое"]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 75
        tableView.layoutMargins = .init(top: 26, left: 16, bottom: 26, right: 16)
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stubStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stubImageView,stubLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.isHidden = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let stubImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "StubIfNoTrackers")
        return image
    }()
    
    private let stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    // тут добавить таблицу которая берет список категорий из БД
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle( "Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleEdgeInsets = .init(top: 19, left: 8, bottom: 19, right: 8)
        button.addTarget(self, action: #selector(addCategoryButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc
    private func addCategoryButtonDidTap() {
        let newCategoryVC = NewCategoryViewController(viewModel: viewModel)
        present(newCategoryVC, animated: true)
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(stubStackView)
        view.addSubview(addCategoryButton)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            
            tableView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 3),
            tableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            addCategoryButton.topAnchor.constraint(equalToSystemSpacingBelow: tableView.bottomAnchor, multiplier: 3),
            
            stubStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: addCategoryButton.bottomAnchor, multiplier: 2),
        ])
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.visibleCells.forEach { $0.accessoryType = .none }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == items.count - 1 {
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            cell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.textColor = .black
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.backgroundColor = .tBackground
        cell.selectionStyle = .none
        return cell
    }
}

@available(iOS 17, *)
#Preview {
    let model = TrackerCategoryStore()
    let viewModel = TrackerCategoryViewModel(model: model)
    CategoryViewController(viewModel: viewModel)
}
