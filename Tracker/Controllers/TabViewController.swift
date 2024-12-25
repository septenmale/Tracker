//
//  ViewController.swift
//  Tracker
//
//  Created by Viktor on 25/12/2024.
//

import UIKit

final class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabs()
    }

    private func setUpTabs() {
        let TrackersVC = TrackersViewController()
        let StatisticVC = StatisticViewController()
        
        TrackersVC.navigationItem.largeTitleDisplayMode = .automatic
        StatisticVC.navigationItem.largeTitleDisplayMode = .automatic
        
        let nav1 = UINavigationController(rootViewController: TrackersVC)
        let nav2 = UINavigationController(rootViewController: StatisticVC)
        
        nav1.tabBarItem = UITabBarItem(title: "Trackers",
                                       image: UIImage(named: "TrackersTabBarItem"),
                                       tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Statistic",
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

