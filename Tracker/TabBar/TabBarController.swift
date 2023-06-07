//
//  TabBarController.swift
//  Tracker
//
//  Created by Kirill on 30.03.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    enum Constants {
        static let trackersTabTitle = "MainScreen.Trackers.Title".localized()
        static let statisticsTabTitle = "MainScreen.Statistics.Title".localized()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
        tabBar.tintColor = .blue
        
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: Constants.trackersTabTitle,
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        statisticsViewController.tabBarItem = UITabBarItem(
            title: Constants.statisticsTabTitle,
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        let controllers = [trackersViewController, statisticsViewController]
        
        viewControllers = controllers
    }
}

