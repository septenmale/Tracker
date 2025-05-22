//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Viktor Zavhorodnii on 20/05/2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    let viewModel = TrackersViewModel()
    
    func testViewController() {
        let vc = TrackersViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: vc)
        
        assertSnapshot(matching: nav, as: .image(traits: .init(userInterfaceStyle: .light)))
        assertSnapshot(matching: nav, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

}
