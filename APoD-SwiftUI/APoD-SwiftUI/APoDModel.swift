//
//  APoDModel.swift
//  APoD-SwiftUI
//
//  Created by Kuixi Song on 7/22/23.
//

import Foundation

struct APoDModel: Codable, Identifiable, Hashable, Equatable {

    enum MediaType: String, Codable {

        case image
        case video

        enum CodingKeys: String, CodingKey {
            case image = "image"
            case video = "video"
        }

    }

    let dateString: String
    let explanation: String
    let imageHDURL: URL?
    let videoThumbnailURL: URL?
    let url: URL
    let title: String
    let mediaType: MediaType
    let copyright: String?

    var date: Date? {
        return Utils.dateFormatter.date(from: dateString)
    }

    var id: String {
        return dateString
    }

    enum CodingKeys: String, CodingKey {
        case dateString = "date"
        case explanation = "explanation"
        case imageHDURL = "hdurl"
        case videoThumbnailURL = "thumbnail_url"
        case url = "url"
        case title = "title"
        case mediaType = "media_type"
        case copyright = "copyright"
    }

}
