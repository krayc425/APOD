//
//  ContentView.swift
//  APoD-SwiftUI
//
//  Created by Kuixi Song on 7/22/23.
//

import SwiftUI
import YouTubePlayerKit

struct APoDView: View {

  @State private var apodModel: APoDModel?
  @State private var currentDate: Date = .now
  @State private var isSelectingDate: Bool = false
  @State private var isPresentImageFullScreen: Bool = false

  var body: some View {
    NavigationStack {
      List {
        if let apodModel {
          Section {
            switch apodModel.mediaType {
              case .image:
                APoDImageView(imageURL: apodModel.url)
                  .onTapGesture {
                    isPresentImageFullScreen = true
                  }
                  .fullScreenCover(isPresented: $isPresentImageFullScreen, content: {
                    APoDFullScreenImageView(imageURL: apodModel.imageHDURL ?? apodModel.url)
                  })
                  .listRowInsets(EdgeInsets())
              case .video:
                let youtubePlayer = YouTubePlayer(
                  source: .url(apodModel.url.absoluteString),
                  configuration: .init(fullscreenMode: .system))
                YouTubePlayerView(youtubePlayer) { state in
                  switch state {
                    case .idle:
                      if let thumbnailURL = apodModel.videoThumbnailURL {
                        AsyncImage(url: thumbnailURL) { image in
                          image.resizable().scaledToFill()
                        } placeholder: {
                          ProgressView()
                        }
                      }
                    case .ready:
                      EmptyView()
                    case .error(let error):
                      Text(error.localizedDescription)
                  }
                }
                .aspectRatio(Utils.youtubeAspectRatio, contentMode: .fill)
            }
          }
          Section {
            VStack(alignment: .leading) {
              Text(apodModel.title).font(.title).bold()
              Text(apodModel.explanation).font(.body)
            }
          }
          if let copyright = apodModel.copyright {
            Section {
              Text("Credit: \(copyright.trimmingCharacters(in: .whitespacesAndNewlines))").font(.body).bold()
            }
          }
        } else {
          EmptyView()
        }
      }
      .scrollIndicators(.automatic, axes: .vertical)
      .scrollIndicators(.never, axes: .horizontal)
      .task(id: currentDate) {
        apodModel = await APoDAPIHelper.shared.loadAPoDData(for: currentDate)
      }
      .navigationTitle(currentDate.formatted(date: .long, time: .omitted))
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            isSelectingDate.toggle()
          } label: {
            Image(systemName: "calendar")
          }
          .sheet(isPresented: $isSelectingDate, content: {
            VStack {
              DatePicker(
                "Choose a date",
                selection: $currentDate,
                in: Utils.validDateRange(),
                displayedComponents: .date)
              .datePickerStyle(.graphical)
              .presentationDetents([.medium])
              .presentationDragIndicator(.hidden)
            }
          })
        }
      }
    }
    .onOpenURL(perform: { url in
      guard url.scheme == Utils.widgetScheme else {
        return
      }
      let arr = url.absoluteString.split(separator: "://")
      if arr.count == 2,
         let dateFromURL = Utils.dateFormatter.date(from: String(arr[1])) {
        currentDate = dateFromURL
      }
    })
  }

}

#Preview {
  APoDView()
}
