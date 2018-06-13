//
//  APODModel.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/6.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import Foundation
import SwiftyJSON

struct APODModel: Codable {
    
    let copyright: String?
    let date: Date?
    let explanation: String?
    let media_type: APODMediaType?
    let service_version: String?
    let title: String?
    let url: URL?
    var hdurl: URL?
 
    init?(json: [String: JSON]) {
        self.copyright = json["copyright"]?.stringValue
        if let dateString = json["date"]?.stringValue {
            self.date = apodDateFormatter.date(from: dateString)
        } else {
            return nil
        }
        self.explanation = json["explanation"]?.stringValue
        if let typeString = json["media_type"]?.stringValue {
            self.media_type = APODMediaType(rawValue: typeString)
        } else {
            return nil
        }
        self.service_version = json["service_version"]?.stringValue
        self.title = json["title"]?.stringValue
        if let urlString = json["url"]?.stringValue {
            self.url = URL(string: urlString)
        } else {
            return nil
        }
        if let hdurlString = json["hdurl"]?.stringValue {
            self.hdurl = URL(string: hdurlString)
        } else if self.media_type! == .image {
            return nil
        }
    }
    
    func getVideoURL() -> URL {
        return URL(string: url!.absoluteString.replacingOccurrences(of: "embed", with: "watch"))!
    }
    
}
