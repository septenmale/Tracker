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
        textField.delegate = self
//        emojiCollectionView.isHidden = true
        
        setupElementsInScrollView()
        setupStackView()
        setupTableView()
        setupEmojiAndColorCollectionViews()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("ContentView frame: \(contentView.frame)")
        print("ScrollView contentSize: \(scrollView.contentSize)")
    }
    
    weak var delegate: NewTrackerDelegate?
    
    private let viewModel: TrackersViewModel
    
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var colorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let emojiCollectionViewItems = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪" ]
    let colorsCollectionViewItems: [UIColor] = [
        UIColor.collectionColor1,UIColor.collectionColor2,UIColor.collectionColor3,UIColor.collectionColor4,UIColor.collectionColor5,UIColor.collectionColor6,UIColor.collectionColor7,UIColor.collectionColor8,UIColor.collectionColor9,UIColor.collectionColor10,UIColor.collectionColor11,UIColor.collectionColor12,UIColor.collectionColor13,UIColor.collectionColor14,UIColor.collectionColor15,UIColor.collectionColor16,UIColor.collectionColor17,UIColor.collectionColor18
    ]
    
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
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .tBackground
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .tRed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        button.addTarget(self, action: #selector(createNewHabit), for: .touchUpInside)
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
        stackView.distribution = .fillEqually
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
        
        changeCreateButtonState()
        tableView.reloadData()
    }
    
    private func changeCreateButtonState() {
        
        let isTextFieldValid = !(textField.text?.isEmpty ?? true)
        let isScheduleValid = !selectedDays.isEmpty
        
        if isTextFieldValid && isScheduleValid {
            createButton.backgroundColor = .blackDay
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = .tGray
            createButton.isEnabled = false
        }
        
    }
    
    @objc private  func createNewHabit() {
        
        guard let habitName = textField.text, !habitName.isEmpty else {
            //TODO: Show alert
            return
        }
        
        guard !selectedDays.isEmpty else {
            //TODO: Show alert
            return
        }
        
        viewModel.addTracker(title: habitName, schedule: selectedDays)
        delegate?.didCreateNewTracker()
        
        presentingViewController?.presentingViewController?.dismiss(animated: true)
        
    }
    
    @objc private func backToTrackerTypeVC() {
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    private func setupElementsInScrollView() {
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.red.cgColor
        contentView.addSubview(textField)
        contentView.addSubview(warningLabel)
        contentView.addSubview(tableView)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorsCollectionView)
        contentView.addSubview(buttonStackView)
        
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
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupEmojiAndColorCollectionViews() {
        
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
        
        emojiCollectionView.isScrollEnabled = false
        colorsCollectionView.isScrollEnabled = false
        
        emojiCollectionView.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: EmojiCollectionCell.reuseIdentifier)
        emojiCollectionView.register(EmojiCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiCollectionHeader.reuseIdentifier)
        colorsCollectionView.register(ColorsCollectionCell.self, forCellWithReuseIdentifier: ColorsCollectionCell.reuseIdentifier)
        colorsCollectionView.register(ColorsCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ColorsCollectionHeader.reuseIdentifier)
        
//        view.addSubview(emojiCollectionView)
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(colorsCollectionView)
        colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false

    }
    
    private func setupStackView() {
//        view.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
    }
    
    private func setupConstraints() {
        
//        view.addSubview(titleLabel)
//        view.addSubview(textField)
//        view.addSubview(tableView)
//        view.addSubview(warningLabel)
        
        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            textField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            // TODO: Проверять есть ли футер у textField если да сделать warningLabel футером
            warningLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor),
            
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiCollectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 50),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorsCollectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorsCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 34),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            buttonStackView.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            
        ])
        
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
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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

extension NewHabitViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 38
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        guard updatedText.count <= maxLength else { warningLabel.isHidden = false; return false }
        warningLabel.isHidden = true
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        warningLabel.isHidden = true
        changeCreateButtonState()
        return true
    }
    
}
