//
//  CollectionFooter.swift
//  Tracker
//
//  Created by Viktor on 05/01/2025.
//

//import UIKit
//
//final class CollectionFooter: UICollectionReusableView {
//    
//    static let reuseIdentifier = "CollectionFooter"
//    
//    lazy private var plusButton: UIButton = {
//        let button = UIButton()
//        //TODO: изменить на безцветную
//        button.setImage(UIImage(named: "buttonPlus"), for: .normal)
////        button.backgroundColor = UIColor(named: "Color selection 5")
//        button.addTarget(self, action: #selector(markAsDone), for: .touchUpInside)
//        return button
//    }()
//    
//     let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "0 дней"
//        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        return label
//    }()
//    
//    private let stackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.spacing = 8
//        stackView.alignment = .center
//        stackView.distribution = .equalSpacing
//        return stackView
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        addSubview(stackView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        plusButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        setupStackView()
//        
//        NSLayoutConstraint.activate([
//            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
//            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
//            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
//            
//            plusButton.widthAnchor.constraint(equalToConstant: 34),
//            plusButton.heightAnchor.constraint(equalToConstant: 34),
//            
//        ])
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    @objc private func markAsDone() {
//        
//    }
//    
//    private func setupStackView() {
//        stackView.addArrangedSubview(titleLabel)
//        stackView.addArrangedSubview(plusButton)
//    }
//    
//}
