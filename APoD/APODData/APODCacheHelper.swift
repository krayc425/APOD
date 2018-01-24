//
//  APODCacheHelper.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/23.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import Kingfisher

class APODCacheHelper: NSObject {
    
    static let shared: APODCacheHelper = APODCacheHelper()
    
    private override init() {
        
    }
    
    // MARK: - Favorite
    
    func addFavorite(model: APODModel) {
        var array = (kUserDefaults.value(forKey: "favorite_apod") as? [String]) ?? []
        let dateString = apodDateFormatter.string(from: model.date!)
        if !array.contains(dateString) {
            array.append(dateString)
        }
        kUserDefaults.set(array, forKey: "favorite_apod")
        kUserDefaults.synchronize()
        
        APODWidgetHelper.shared.addWidgetModel(model: model)
    }
    
    func removeFavorite(model: APODModel) {
        var array = (kUserDefaults.value(forKey: "favorite_apod") as? [String]) ?? []
        let dateString = apodDateFormatter.string(from: model.date!)
        if array.contains(dateString) {
            array.remove(at: array.index(of: dateString)!)
        }
        kUserDefaults.set(array, forKey: "favorite_apod")
        kUserDefaults.synchronize()
        
        APODWidgetHelper.shared.removeWidgetModel(model: model)
    }
    
    func getFavoriteModels() -> [APODModel]? {
        return (kUserDefaults.value(forKey: "favorite_apod") as? [String])?.map {
            getCacheModel(on: apodDateFormatter.date(from: $0)!)!
        }
    }
    
    func isFavoriteModel(on date: Date) -> Bool {
        if let array = (kUserDefaults.value(forKey: "favorite_apod") as? [String]) {
            return array.contains(apodDateFormatter.string(from: date))
        }
        return false
    }
    
    // MARK: - Cache
    
    func cacheModel(model: APODModel) {
        var dict = (kUserDefaults.value(forKey: "cache_apod") as? Dictionary<String, Data>) ?? [:]
        if let date = model.date {
            dict[apodDateFormatter.string(from: date)] = try? apodJSONEncoder.encode(model)
            kUserDefaults.set(dict, forKey: "cache_apod")
            kUserDefaults.synchronize()
        }
    }
    
    func getCacheModel(on date: Date) -> APODModel? {
        var dict = (kUserDefaults.value(forKey: "cache_apod") as? Dictionary<String, Data>) ?? [:]
        if let data = dict[apodDateFormatter.string(from: date)] {
            return try? apodJSONDecoder.decode(APODModel.self, from: data)
        }
        return nil
    }
    
}
