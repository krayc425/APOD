//
//  APoDCalendar.swift
//  APoDCalendar
//
//  Created by Kuixi Song on 7/28/23.
//

import Intents
import WidgetKit
import SwiftUI
import UIKit

struct APoDCalendarProvider: IntentTimelineProvider {

    typealias Intent = APoDCalendarIntent

    func placeholder(in context: Context) -> APoDWidgetEntry {
        return APoDWidgetEntry.emptyEntry
    }

    func getSnapshot(for configuration: APoDCalendarIntent, in context: Context, completion: @escaping (APoDWidgetEntry) -> ()) {
        let date = configuration.selectDate?.date ?? .now
        guard Utils.validDateRange().contains(date) else {
            completion(APoDWidgetEntry.invalidDateEntry)
            return
        }
        APoDWidgetEntry.getSnapshot(for: date, completion: completion)
    }

    func getTimeline(for configuration: APoDCalendarIntent, in context: Context, completion: @escaping (Timeline<APoDWidgetEntry>) -> ()) {
        let date = configuration.selectDate?.date ?? .now
        guard Utils.validDateRange().contains(date) else {
            let timeline = Timeline(entries: [APoDWidgetEntry.invalidDateEntry], policy: .atEnd)
            completion(timeline)
            return
        }
        APoDWidgetEntry.getTimeline(for: date, isFromIntent: true, completion: completion)
    }

}

struct APoDCalendar: Widget {

    let kind: String = "APoDCalendar"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: APoDCalendarIntent.self, provider: APoDCalendarProvider()) { entry in
            APoDWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("APoD on your chosen date")
        .supportedFamilies([.systemSmall, .systemLarge, .systemExtraLarge])
        .contentMarginsDisabledIfAvailable()
    }

}
