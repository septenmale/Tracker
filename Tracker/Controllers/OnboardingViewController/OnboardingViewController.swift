//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Viktor Zavhorodnii on 24/04/2025.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        setupUI()
    }
    
    private lazy var pages: [UIViewController] = {
        let first = FirstScreenVC()
        let second = SecondScreenVC()
        
        return [first, second]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("onbButton", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.titleEdgeInsets = .init(top: 19, left: 8, bottom: 19, right: 8)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc
    private func didTapContinue() {
        UserDefaults.standard.setValue(true, forKey: "isOnboardingCompleted")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
            .changeRootViewController(to: TabViewController())
    }
    
    private func setupUI() {
        view.addSubview(continueButton)
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            continueButton.topAnchor.constraint(equalToSystemSpacingBelow: pageControl.bottomAnchor, multiplier: 3),
            continueButton.heightAnchor.constraint(equalToConstant: 60),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
        ])
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else {
            return pages.last
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = vcIndex + 1
        
        guard nextIndex < pages.count else {
            return pages.first
        }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = currentIndex
        }
    }
}
