//
//  TrackerModel.swift
//  Tracker
//
//  Created by Viktor on 30/12/2024.
//

import Foundation

enum Weekday: String {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

struct Tracker {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: [Weekday]
}
