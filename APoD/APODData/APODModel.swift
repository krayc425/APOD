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
    
    var copyright: String?
    var date: Date?
    var explanation: String?
    var hdurl: URL?
    var media_type: APODMediaType?
    var service_version: String?
    var title: String?
    var url: URL?
 
    init(json: [String: JSON]) {
        self.copyright = json["copyright"]?.stringValue
        if let dateString =  json["date"]?.stringValue {
            self.date = apodDateFormatter.date(from: dateString)
        }
        self.explanation = json["explanation"]?.stringValue
        if let hdurlString = json["hdurl"]?.stringValue {
            self.hdurl = URL(string: hdurlString)
        }
        if let typeString = json["media_type"]?.stringValue {
            self.media_type = APODMediaType(rawValue: typeString)
        }
        self.service_version = json["service_version"]?.stringValue
        self.title = json["title"]?.stringValue
        if let urlString = json["url"]?.stringValue {
            self.url = URL(string: urlString)
        }
    }
    
    func getVideoURL() -> URL {
        return URL(string: url!.absoluteString.replacingOccurrences(of: "embed", with: "watch"))!
    }
    
}
