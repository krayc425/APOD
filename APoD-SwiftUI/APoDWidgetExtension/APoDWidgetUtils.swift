//
//  WidgetUtils.swift
//  APoD-SwiftUI
//
//  Created by Kuixi Song on 7/28/23.
//

import Foundation
import SwiftUI
import WidgetKit

struct APoDWidgetEntry: TimelineEntry {

  static let emptyEntry = APoDWidgetEntry(image: nil, dateString: nil)
  static let invalidDateEntry = APoDWidgetEntry(image: nil, dateString: nil, errorString: "Invalid date")

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

  static func getSnapshot(for date: Date, completion: @escaping (APoDWidgetEntry) -> ()) {
    APoDAPIHelper.shared.loadAPoDData(for: date) { model in
      if let model {
        APoDAPIHelper.shared.loadImageData(imageURL: model.imageURL) { image in
          if let image {
            completion(APoDWidgetEntry(image: image, dateString: model.dateString))
          } else {
            completion(APoDWidgetEntry.emptyEntry)
          }
        }
      } else {
        completion(APoDWidgetEntry.emptyEntry)
      }
    }
  }

  static func getTimeline(for date: Date, completion: @escaping (Timeline<APoDWidgetEntry>) -> ()) {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)
    let policy: TimelineReloadPolicy = if let nextDay { .after(nextDay) } else { .atEnd }
    let emptyTimeline = Timeline(entries: [Self.emptyEntry], policy: policy)
    APoDAPIHelper.shared.loadAPoDData(for: date) { model in
      if let model {
        APoDAPIHelper.shared.loadImageData(imageURL: model.imageURL) { image in
          if let image {
            let entry = APoDWidgetEntry(image: image, dateString: model.dateString)
            let timeline = Timeline(entries: [entry], policy: policy)
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

struct APoDWidgetEntryView : View {

  var entry: APoDWidgetEntry

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
    .containerBackground(.black, for: .widget)
    .widgetURL(URL(string: "\(Utils.widgetScheme)://\(Utils.dateFormatter.string(from: entry.date))"))
  }

}
