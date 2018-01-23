//
//  Constants.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/6.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import Foundation
import UIKit

let kScreenWidth    : CGFloat = UIScreen.main.bounds.width
let kScreenHeight   : CGFloat = UIScreen.main.bounds.height

let kAppID = "1173315594"
let kGroupID = "group.com.krayc.Triplorex"
let kUserDefaults = UserDefaults(suiteName: kGroupID)!

let minimumDate = Date(timeIntervalSince1970: 9297 * 24 * 60 * 60)
let maximumDate = Date()

let isiPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad

let apodDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
}()

let apodDatePicker: UIDatePicker = {
    let datePicker = UIDatePicker(frame: CGRect(x: 0,
                                                y: 25,
                                                width: isiPad ? 320 : kScreenWidth,
                                                height: isiPad ? 200 : 250))
    datePicker.datePickerMode = .date
    datePicker.maximumDate = maximumDate
    datePicker.minimumDate = minimumDate
    datePicker.tintColor = UIColor.apod
    return datePicker
}()

let apodJSONDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(apodDateFormatter)
    return decoder
}()

let apodJSONEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(apodDateFormatter)
    return encoder
}()

let videoRatioArray: [(ratio: CGFloat, description: String)] = [(9.0 / 16.0, "16:9"),
                                                                (3.0 / 4.0, "4:3")]
