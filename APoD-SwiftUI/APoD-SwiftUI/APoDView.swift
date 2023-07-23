//
//  ContentView.swift
//  APoD-SwiftUI
//
//  Created by Kuixi Song on 7/22/23.
//

import SwiftUI
import YouTubePlayerKit

struct APoDImageView: View {

    var imageURL: URL

    var body: some View {
        AsyncImage(url: imageURL) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            ProgressView()
        }
    }

}

struct APoDFullScreenImageView: View {

    @Environment(\.dismiss) var dismiss
    var imageURL: URL

    var body: some View {
        VStack {
            APoDImageView(imageURL: imageURL)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }

}

struct APoDView: View {

    @State private var apodModel: APoDModel?
    @State private var currentDate: Date = .now
    @State private var isSelectingDate: Bool = false
    @State private var isPresentImageFullScreen: Bool = false

    var body: some View {
        List {
            if let apodModel {
                Section {
                    ZStack {
                        switch apodModel.mediaType {
                        case .image:
                            APoDImageView(imageURL: apodModel.url)
                            .onTapGesture {
                                isPresentImageFullScreen = true
                            }
                            .fullScreenCover(isPresented: $isPresentImageFullScreen, content: {
                                APoDFullScreenImageView(imageURL: apodModel.imageHDURL ?? apodModel.url)
                            })
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
                    .listRowInsets(EdgeInsets())
                    .frame(maxWidth: .infinity, alignment: .center)
                } header: {
                    HStack {
                        Text(currentDate, style: .date)
                        Spacer()
                        Button {
                            isSelectingDate.toggle()
                        } label: {
                            Image(systemName: "calendar")
                        }
                        .sheet(isPresented: $isSelectingDate, content: {
                            DatePicker(
                                "Choose a date",
                                selection: $currentDate,
                                in: Utils.validDateRange(),
                                displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                        })
                    }
                }
                .headerProminence(.increased)
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
            isSelectingDate = false
            apodModel = await APoDAPIHelper.shared.loadAPoDData(for: currentDate)
        }
    }

}

@available(iOS 17.0, *)
#Preview {
    APoDView()
}
