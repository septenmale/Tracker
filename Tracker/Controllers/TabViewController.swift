//
//  ViewController.swift
//  Tracker
//
//  Created by Viktor on 25/12/2024.
//

import UIKit

final class TabViewController: UITabBarController {

    let viewModel = TrackersViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabs()
    }

    private func setUpTabs() {
        let TrackersVC = TrackersViewController(viewModel: viewModel)
        let StatisticVC = StatisticViewController(viewModel: viewModel)
        
        TrackersVC.navigationItem.largeTitleDisplayMode = .automatic
        StatisticVC.navigationItem.largeTitleDisplayMode = .automatic
        
        let nav1 = UINavigationController(rootViewController: TrackersVC)
        let nav2 = UINavigationController(rootViewController: StatisticVC)
        
        nav1.tabBarItem = UITabBarItem(title: NSLocalizedString("trackersLabel", comment: ""),
                                       image: UIImage(named: "TrackersTabBarItem"),
                                       tag: 1)
        nav2.tabBarItem = UITabBarItem(title: NSLocalizedString("statisticLabel", comment: ""),
                                       image: UIImage(named: "StatTabBarITem"),
                                       tag: 2)
        
        for nav in [nav1, nav2] {
            nav.navigationBar.prefersLargeTitles = true
        }
        
        setViewControllers(
            [nav1, nav2],
            animated: true
        )
    }
    
}

