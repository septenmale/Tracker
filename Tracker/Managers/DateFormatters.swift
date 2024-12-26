//
//  DateFormatters.swift
//  Tracker
//
//  Created by Viktor on 26/12/2024.
//

import Foundation

extension DateFormatter {
    static let trackerVCDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
}
