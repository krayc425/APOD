//
//  APoDToday.swift
//  APoDToday
//
//  Created by Kuixi Song on 7/23/23.
//

import WidgetKit
import SwiftUI
import UIKit

struct APoDProvider: TimelineProvider {

    static let emptyEntry = APoDTodayEntry(image: nil, dateString: nil)

    func placeholder(in context: Context) -> APoDTodayEntry {
        return Self.emptyEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (APoDTodayEntry) -> ()) {
        APoDAPIHelper.shared.loadAPoDData(for: Date()) { model in
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

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        APoDAPIHelper.shared.loadAPoDData(for: Date()) { model in
            if let model {
                APoDAPIHelper.shared.loadImageData(imageURL: model.imageURL) { image in
                    if let image {
                        let entry = APoDTodayEntry(image: image, dateString: model.dateString)
                        let timeline = Timeline(entries: [entry], policy: .atEnd)
                        completion(timeline)
                    } else {
                        let timeline = Timeline(entries: [Self.emptyEntry], policy: .atEnd)
                        completion(timeline)
                    }
                }
            } else {
                let timeline = Timeline(entries: [Self.emptyEntry], policy: .atEnd)
                completion(timeline)
            }
        }
    }

}

struct APoDTodayEntry: TimelineEntry {

    let image: UIImage?
    let dateString: String?
    let isEmpty: Bool

    var date: Date {
        if let dateString {
            return Utils.dateFormatter.date(from: dateString) ?? .now
        } else {
            return .now
        }
    }

    init(image: UIImage?, dateString: String?) {
        self.image = image
        self.dateString = dateString
        self.isEmpty = dateString == nil || image == nil
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
                Text(verbatim: "Failed to load")
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(.black)
    }

}

struct APoDToday: Widget {

    let kind: String = "APoDToday"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: APoDProvider()) { entry in
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
