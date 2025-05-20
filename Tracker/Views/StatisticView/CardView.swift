//
//  CardView.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 20/05/2025.
//

import UIKit

final class StatisticCardView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let borderLayer = CAShapeLayer()
    private let numberLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 16)
        borderLayer.path = path.cgPath
    }
    
    func setValue(_ value: String, text: String) {
        numberLabel.text = value
        subtitleLabel.text = text
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        gradientLayer.colors = [
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 233/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        layer.addSublayer(gradientLayer)
        
        borderLayer.lineWidth = 1
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = borderLayer
        
        // Контент
        numberLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        numberLabel.textColor = .black
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = .black
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(numberLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            numberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            numberLabel.bottomAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.topAnchor, constant: -8),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
