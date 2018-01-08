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
    
    // MARK: - Favorite
    
    func addFavorite(model: APODModel) {
        var array = (UserDefaults.standard.value(forKey: "favorite_apod") as? [String]) ?? []
        let dateString = apodDateFormatter.string(from: model.date!)
        if !array.contains(dateString) {
            array.append(dateString)
        }
        UserDefaults.standard.set(array, forKey: "favorite_apod")
        UserDefaults.standard.synchronize()
    }
    
    func removeFavorite(model: APODModel) {
        var array = (UserDefaults.standard.value(forKey: "favorite_apod") as? [String]) ?? []
        let dateString = apodDateFormatter.string(from: model.date!)
        if array.contains(dateString) {
            array.remove(at: array.index(of: dateString)!)
        }
        UserDefaults.standard.set(array, forKey: "favorite_apod")
        UserDefaults.standard.synchronize()
    }
    
    func getFavoriteModels() -> [APODModel]? {
        return (UserDefaults.standard.value(forKey: "favorite_apod") as? [String])?.map {
            getCacheModel(on: apodDateFormatter.date(from: $0)!)!
        }
    }
    
    func isFavoriteModel(on date: Date) -> Bool {
        if let array = (UserDefaults.standard.value(forKey: "favorite_apod") as? [String]) {
            return array.contains(apodDateFormatter.string(from: date))
        }
        return false
    }
    
    // MARK: - Cache
    
    func cacheModel(model: APODModel) {
        var dict = (UserDefaults.standard.value(forKey: "cache_apod") as? Dictionary<String, Data>) ?? [:]
        if let date = model.date {
            dict[apodDateFormatter.string(from: date)] = try? apodJSONEncoder.encode(model)
            UserDefaults.standard.set(dict, forKey: "cache_apod")
            UserDefaults.standard.synchronize()
        }
    }

    func getCacheModel(on date: Date) -> APODModel? {
        var dict = (UserDefaults.standard.value(forKey: "cache_apod") as? Dictionary<String, Data>) ?? [:]
        if let data = dict[apodDateFormatter.string(from: date)] {
            return try? apodJSONDecoder.decode(APODModel.self, from: data)
        }
        return nil
    }
    
}
