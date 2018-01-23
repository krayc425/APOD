//
//  APODHelper.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/6.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class APODHelper: NSObject {

    static let shared: APODHelper = APODHelper()
    
    private override init() {
        
    }
    
    func getAPODInfo(on date: Date, completionHandler: @escaping (_ model: APODModel?) -> Void) {
        let url = URL(string: "https://api.nasa.gov/planetary/apod")!
        let para: Parameters = ["api_key": APOD_API_KEY,
                                "date": apodDateFormatter.string(from: date)]
        Alamofire.request(url, method: .get, parameters: para).responseJSON { (response) in
            if let json = response.result.value {
                completionHandler(APODModel(json: JSON(json).dictionaryValue))
            }
        }
    }
    
}
