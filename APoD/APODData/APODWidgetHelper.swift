//
//  APODWidgetHelper.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/24.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import Foundation
import Kingfisher

typealias APODImageData = Data
typealias APODWidgetModel = [String: APODImageData]

private let widgetKey = "widget_dict"

class APODWidgetHelper: NSObject {
    
    static let shared: APODWidgetHelper = APODWidgetHelper()
    
    private override init() {
        
    }
    
    func addWidgetModel(model: APODModel) {
        guard model.media_type! == .image else {
            return
        }
        
        var widgetDict = kUserDefaults.value(forKey: widgetKey) as? APODWidgetModel ?? [:]
        
        let resource = ImageResource(downloadURL: model.url!, cacheKey: apodDateFormatter.string(from: model.date!))
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { (image, _, _, _) in
            if let image = image {
                widgetDict[apodDateFormatter.string(from: model.date!)] = UIImageJPEGRepresentation(image, 0.25)
            }
        }
        
        kUserDefaults.set(widgetDict, forKey: widgetKey)
        kUserDefaults.synchronize()
    }
    
    func removeWidgetModel(model: APODModel) {
        guard model.media_type! == .image else {
            return
        }
        
        var widgetDict = kUserDefaults.value(forKey: widgetKey) as? APODWidgetModel ?? [:]
        
        widgetDict[apodDateFormatter.string(from: model.date!)] = nil
        
        kUserDefaults.set(widgetDict, forKey: widgetKey)
        kUserDefaults.synchronize()
    }
    
    func getWidgetModelDict() -> APODWidgetModel {
        return kUserDefaults.value(forKey: widgetKey) as! APODWidgetModel
    }
    
}
