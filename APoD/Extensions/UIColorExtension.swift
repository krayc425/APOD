//
//  UIColorExtension.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/6.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let apod: UIColor = {
        return UIColor(named: "APOD")!
    }()
    
    static let apodReversed: UIColor = {
        return UIColor(named: "APOD-Reverse")!
    }()
    
}
