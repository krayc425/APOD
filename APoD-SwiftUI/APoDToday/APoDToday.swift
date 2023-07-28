//
//  APoDToday.swift
//  APoDToday
//
//  Created by Kuixi Song on 7/23/23.
//

import WidgetKit
import SwiftUI
import UIKit

struct APoDTodayProvider: TimelineProvider {

    func placeholder(in context: Context) -> APoDWidgetEntry {
        return APoDWidgetEntry.emptyEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (APoDWidgetEntry) -> ()) {
        APoDWidgetEntry.getSnapshot(for: .now, completion: completion)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<APoDWidgetEntry>) -> ()) {
        APoDWidgetEntry.getTimeline(for: .now, isFromIntent: false, completion: completion)
    }

}

struct APoDToday: Widget {

    let kind: String = "APoDToday"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: APoDTodayProvider()) { entry in
            APoDWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's APoD")
        .supportedFamilies([.systemSmall, .systemLarge, .systemExtraLarge])
        .contentMarginsDisabledIfAvailable()
    }

}
