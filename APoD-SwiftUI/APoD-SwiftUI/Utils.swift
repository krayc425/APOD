//
//  Utils.swift
//  APoD-SwiftUI
//
//  Created by Kuixi Song on 7/22/23.
//

import Foundation

enum Utils {

    static let youtubeAspectRatio: CGFloat = 16.0 / 9.0

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    static func validDateRange() -> ClosedRange<Date> {
        let minimumDate = Date(timeIntervalSince1970: 9297 * 24 * 60 * 60)
        let maximumDate = Date()
        return minimumDate...maximumDate
    }

}
