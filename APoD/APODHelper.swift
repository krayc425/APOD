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
    
    func getAPODInfo(on date: Date, completionHandler: @escaping (_ model: APODModel) -> Void) {
        let url = URL(string: "https://api.nasa.gov/planetary/apod")!
        let para: Parameters = ["api_key": APOD_API_KEY,
                                "date": apodDateFormatter.string(from: date)]
        Alamofire.request(url, method: .get, parameters: para).responseJSON { (response) in
            if let json = response.result.value {
                completionHandler(APODModel(json: JSON(json).dictionaryValue))
            }
        }
    }
    
    func addFavorite(model: APODModel) {
        var dict = (UserDefaults.standard.value(forKey: "favorite_apod") as? Dictionary<String, Data>) ?? [:]
        dict[apodDateFormatter.string(from: model.date!)] = try? apodJSONEncoder.encode(model)
        UserDefaults.standard.set(dict, forKey: "favorite_apod")
        UserDefaults.standard.synchronize()
    }
    
    func removeFavorite(model: APODModel) {
        var dict = (UserDefaults.standard.value(forKey: "favorite_apod") as? Dictionary<String, Data>) ?? [:]
        dict[apodDateFormatter.string(from: model.date!)] = nil
        UserDefaults.standard.set(dict, forKey: "favorite_apod")
        UserDefaults.standard.synchronize()
    }
    
    func getFavoriteModel(on date: Date) -> APODModel? {
        var dict = (UserDefaults.standard.value(forKey: "favorite_apod") as? Dictionary<String, Data>) ?? [:]
        if let data = dict[apodDateFormatter.string(from: date)] {
            return try? apodJSONDecoder.decode(APODModel.self, from: data)
        }
        return nil
    }
    
    func getFavoriteModels() -> [APODModel]? {
        if let dict = UserDefaults.standard.value(forKey: "favorite_apod") as? Dictionary<String, Data> {
            return dict.values.map {
                try! apodJSONDecoder.decode(APODModel.self, from: $0)
                }.sorted(by: { (model1, model2) -> Bool in
                    (model1.date?.timeIntervalSince1970 ?? 0.0) < (model2.date?.timeIntervalSince1970 ?? 0.0)
                })
        }
        return nil
    }
    
}
