//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 25/04/2025.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    private let viewModel: TrackerCategoryViewModel
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("newCategoryTitle", comment: "")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("newCategoryTextFieldPlaceholder", comment: "")
        textField.backgroundColor = .tBackground
        textField.layer.cornerRadius = 16
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("confirmButtonTitle", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .tGray
        button.layer.cornerRadius = 16
        button.titleEdgeInsets = .init(top: 19, left: 8, bottom: 19, right: 8)
        button.addTarget(self, action: #selector(submitButtonDidTap), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: TrackerCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        textField.delegate = self
        setupUI()
    }
    
    @objc
    private func submitButtonDidTap() {
        guard let text = textField.text else { return }
        let textToBeCompared = text.trimmingCharacters(in: .whitespaces)
        guard textToBeCompared != NSLocalizedString("pinnedCategory", comment: "") else {
            
            let alertController = UIAlertController(
                title: NSLocalizedString("newCategoryErrorMessageTitle", comment: ""),
                message: NSLocalizedString("newCategoryErrorMessageDescription", comment: ""),
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: NSLocalizedString("okButtonTitle", comment: ""), style: .default)
            alertController.addAction(okAction)
            present(alertController, animated: true)
            
            return
        }
        viewModel.saveCategory(name: text)
        dismiss(animated: true)
    }
    
    private func changeButtonState(isTextEmpty: Bool) {
        submitButton.backgroundColor = isTextEmpty ? .tGray : .black
        submitButton.isEnabled = !isTextEmpty
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            
            textField.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 3),
            textField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            submitButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 60),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: submitButton.bottomAnchor, multiplier: 2)
        ])
    }
}

//MARK: - TextField Delegate
extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        let isEmpty = updatedText.trimmingCharacters(in: .whitespaces).isEmpty
        
        changeButtonState(isTextEmpty: isEmpty)
        return true
    }
}
