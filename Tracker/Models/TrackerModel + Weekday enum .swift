//
//  TrackerModel.swift
//  Tracker
//
//  Created by Viktor on 30/12/2024.
//

import UIKit

public enum Weekday: String, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
}
