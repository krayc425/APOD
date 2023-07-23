//
//  APoDToday.swift
//  APoDToday
//
//  Created by Kuixi Song on 7/23/23.
//

import Intents
import WidgetKit
import SwiftUI
import UIKit

struct APoDProvider: TimelineProvider, IntentTimelineProvider {

    typealias Intent = APoDTodayIntentsIntent

    static let emptyEntry = APoDTodayEntry(image: nil, dateString: nil)
    static let invalidDateEntry = APoDTodayEntry(image: nil, dateString: nil, errorString: "Invalid date")

    func placeholder(in context: Context) -> APoDTodayEntry {
        return Self.emptyEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (APoDTodayEntry) -> ()) {
        getSnapshot(for: .now, completion: completion)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<APoDTodayEntry>) -> ()) {
        getTimeline(for: .now, isFromIntent: false, completion: completion)
    }

    func getSnapshot(for configuration: APoDTodayIntentsIntent, in context: Context, completion: @escaping (APoDTodayEntry) -> ()) {
        let date = configuration.selectDate?.date ?? .now
        guard Utils.validDateRange().contains(date) else {
            completion(Self.invalidDateEntry)
            return
        }
        getSnapshot(for: date, completion: completion)
    }

    func getTimeline(for configuration: APoDTodayIntentsIntent, in context: Context, completion: @escaping (Timeline<APoDTodayEntry>) -> ()) {
        let date = configuration.selectDate?.date ?? .now
        guard Utils.validDateRange().contains(date) else {
            let timeline = Timeline(entries: [Self.invalidDateEntry], policy: .atEnd)
            completion(timeline)
            return
        }
        getTimeline(for: date, isFromIntent: true, completion: completion)
    }

    private func getSnapshot(for date: Date, completion: @escaping (APoDTodayEntry) -> ()) {
        APoDAPIHelper.shared.loadAPoDData(for: date) { model in
            if let model {
                APoDAPIHelper.shared.loadImageData(imageURL: model.imageURL) { image in
                    if let image {
                        completion(APoDTodayEntry(image: image, dateString: model.dateString))
                    } else {
                        completion(Self.emptyEntry)
                    }
                }
            } else {
                completion(Self.emptyEntry)
            }
        }
    }

    private func getTimeline(for date: Date, isFromIntent: Bool, completion: @escaping (Timeline<APoDTodayEntry>) -> ()) {
        let emptyTimeline = Timeline(entries: [Self.emptyEntry], policy: isFromIntent ? .never : .atEnd)
        APoDAPIHelper.shared.loadAPoDData(for: date) { model in
            if let model {
                APoDAPIHelper.shared.loadImageData(imageURL: model.imageURL) { image in
                    if let image {
                        let entry = APoDTodayEntry(image: image, dateString: model.dateString)
                        let timeline = Timeline(entries: [entry], policy: isFromIntent ? .never : .atEnd)
                        completion(timeline)
                    } else {
                        completion(emptyTimeline)
                    }
                }
            } else {
                completion(emptyTimeline)
            }
        }
    }

}

struct APoDTodayEntry: TimelineEntry {

    let image: UIImage?
    let dateString: String?
    let errorString: String?
    let isEmpty: Bool

    var date: Date {
        if let dateString {
            return Utils.dateFormatter.date(from: dateString) ?? .now
        } else {
            return .now
        }
    }

    init(image: UIImage?, dateString: String?, errorString: String? = nil) {
        self.image = image
        self.dateString = dateString
        self.errorString = errorString
        self.isEmpty = dateString == nil || image == nil || errorString != nil
    }

}

struct APoDTodayEntryView : View {

    var entry: APoDProvider.Entry

    var body: some View {
        VStack {
            if let image = entry.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                if let errorString = entry.errorString {
                    Text(errorString)
                } else {
                    Text("Failed to load")
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(.black)
        .widgetURL(URL(string: "\(Utils.widgetScheme)://\(Utils.dateFormatter.string(from: entry.date))"))
    }

}

struct APoDToday: Widget {

    let kind: String = "APoDToday"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: APoDTodayIntentsIntent.self, provider: APoDProvider()) { entry in
            APoDTodayEntryView(entry: entry)
        }
        .configurationDisplayName("Astronomy Picture of the Day")
        .supportedFamilies([.systemSmall, .systemLarge, .systemExtraLarge])
        .contentMarginsDisabledIfAvailable()
    }

}

extension WidgetConfiguration {

    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }

}

extension View {

    func widgetBackground(_ color: Color) -> some View {
        if #available(iOSApplicationExtension 17.0, macOSApplicationExtension 14.0, *) {
            return containerBackground(color, for: .widget)
        } else {
            return background(color)
        }
    }

}
