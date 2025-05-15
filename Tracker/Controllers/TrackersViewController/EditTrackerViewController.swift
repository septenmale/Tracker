//
//  EditTrackerViewController.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 13/05/2025.
//

import UIKit
// TODO: Возможно заполнения полей вынести в отдельный метод и ViewDidLoad
final class EditTrackerViewController: UIViewController, ChangeButtonStateDelegate {
    init(
        data: EditableTrackerData,
        trackersViewModel: TrackersViewModel,
        categoryViewModel: TrackerCategoryViewModel
    ) {
        self.trackerViewModel = trackersViewModel
        self.categoryViewModel = categoryViewModel
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    private let data: EditableTrackerData
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        textField.delegate = self
        emojiCollectionView.changeButtonStateDelegate = self
        colorsCollectionView.changeButtonStateDelegate = self
        
        setupElementsInScrollView()
        setupStackView()
        setupTableView()
        setupConstraints()
        updateData()
    }
    
    //    weak var newTrackerDelegate: NewTrackerDelegate?
    
    private let trackerViewModel: TrackersViewModel
    private let categoryViewModel: TrackerCategoryViewModel
    private lazy var categoryVC = CategoryViewController(viewModel: categoryViewModel)
    
    private var selectedDays: [Int] = []
    private var isHabit: Bool {
        !data.tracker.schedule.isEmpty
    }
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private let emojiCollectionView = EmojiCollectionView()
    private let colorsCollectionView = ColorsCollectionView()
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    private lazy var items: [(String, String)]  = {
        var result: [(String, String)] = [(NSLocalizedString("category", comment: ""), "")]
        if isHabit {
            result.append((NSLocalizedString("schedule", comment: ""), ""))
        }
        return result
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = isHabit
        ? NSLocalizedString("editHabitTitle", comment: "")
        : NSLocalizedString("editHabitTitle", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var daysAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
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
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
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
        label.text = NSLocalizedString("textLengthWarningLabel", comment: "")
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .tRed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle(NSLocalizedString("createButtonTitle", comment: ""), for: .normal)
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
        button.setTitle(NSLocalizedString("cancelButtonTitle", comment: ""), for: .normal)
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
    
    private func updateData() {
        textField.text = data.tracker.title
        emojiCollectionView.selectedEmoji = data.tracker.emoji
        colorsCollectionView.selectedColor = data.tracker.color
        items[0].1 = data.categoryTitle
        daysAmountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: ""),
            data.completedDays
        )
        if isHabit {
            selectedDays = data.tracker.schedule.map {
                switch $0 {
                case .monday: return 0
                case .tuesday: return 1
                case .wednesday: return 2
                case .thursday: return 3
                case .friday: return 4
                case .saturday: return 5
                case .sunday: return 6
                }
            }
            
            updateScheduleSubtitle(selectedDays)
        }
        changeCreateButtonState()
        tableView.reloadData()
    }
    
    private func updateScheduleSubtitle(_ selectedDays: [Int]) {
        let weekdaysShort = [NSLocalizedString("mondayShort", comment: ""), NSLocalizedString("tuesdayShort", comment: ""), NSLocalizedString("wednesdayShort", comment: ""), NSLocalizedString("thursdayShort", comment: ""), NSLocalizedString("fridayShort", comment: ""), NSLocalizedString("saturdayShort", comment: ""), NSLocalizedString("sundayShort", comment: "")]
        
        if selectedDays.count == weekdaysShort.count {
            items[1].1 = NSLocalizedString("everyDaySubtitle", comment: "")
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
    
    func changeCreateButtonState() {
        let isTextFieldValid = !(textField.text?.isEmpty ?? true)
        var isScheduleValid = !selectedDays.isEmpty
        let isEmojiSelected = emojiCollectionView.selectedEmoji != nil
        let isColorSelected = colorsCollectionView.selectedColor != nil
        // Возможно вынести в отдельную функцию/переменную
        if !isHabit {
            isScheduleValid = true
        }
        if isTextFieldValid && isScheduleValid && isEmojiSelected && isColorSelected && items[0].1 != "" {
            createButton.backgroundColor = .blackDay
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = .tGray
            createButton.isEnabled = false
        }
    }
    //TODO: Добавить логику перезаписи. VC -> VM -> M
    @objc private  func createNewHabit() {
        guard let habitName = textField.text else {
            return
        }
        
        guard let selectedEmoji = emojiCollectionView.selectedEmoji else {
            return
        }
        
        guard let selectedColor = colorsCollectionView.selectedColor else {
            return
        }
        
        let categoryName = items[0].1
        
        trackerViewModel.addTracker(title: habitName, schedule: selectedDays, emoji: selectedEmoji, color: selectedColor, category: categoryName)
        //        newTrackerDelegate?.didCreateNewTracker()
        
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    //TODO: ДОбавить логику закрытия
    @objc private func backToTrackerTypeVC() {
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    private func setupElementsInScrollView() {
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(daysAmountLabel)
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
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = false
        tableView.clipsToBounds = true
        tableView.backgroundColor = .tBackground
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupStackView() {
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
    }
    
    private func setupConstraints() {
        let rowHeight: CGFloat = 75
        let rowCount = isHabit ? 2 : 1
        let totalHeight = CGFloat(rowCount) * rowHeight
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27), // ??
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            daysAmountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            daysAmountLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            textField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textField.topAnchor.constraint(equalTo: daysAmountLabel.bottomAnchor, constant: 40),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            warningLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor),
            
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: totalHeight),
            
            emojiCollectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 50),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorsCollectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorsCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 34),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            buttonStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonStackView.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
}

extension EditTrackerViewController: UITableViewDelegate {
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
        } else if indexPath.row == 0 {
            present(categoryVC, animated: true)
        }
    }
}

extension EditTrackerViewController: UITableViewDataSource {
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

extension EditTrackerViewController : UITextFieldDelegate {
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

@available(iOS 17.0, *)
#Preview {
    let vm = TrackersViewModel()
    let store = TrackerCategoryStore.shared
    let catVM = TrackerCategoryViewModel(model: store)
    let vc = CategoryViewController(viewModel: catVM)
    let tracker: Tracker = Tracker(id: UUID(), title: "TestTracker", color: .tBlue, emoji: "🍔", schedule: [])
    let data: EditableTrackerData = EditableTrackerData(tracker: tracker, categoryTitle: "Новая категория", completedDays: 4)
    EditTrackerViewController(data: data, trackersViewModel: vm, categoryViewModel: catVM)
}
