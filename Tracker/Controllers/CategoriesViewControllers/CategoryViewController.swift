//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 25/04/2025.
//

import UIKit

final class CategoryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
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
        let newCategoryVC = NewCategoryViewController()
        present(newCategoryVC, animated: true)
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(stubStackView)
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            
            stubStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: addCategoryButton.bottomAnchor, multiplier: 2),
        ])
    }
}

@available(iOS 17, *)
#Preview {
    CategoryViewController()
}
