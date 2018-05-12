//
//  URLExtension.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/3/5.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit

extension URL {
    
    func open() {
        guard Float(UIDevice.current.systemVersion.split(separator: ".")[0])! >= 10.0 else {
            return
        }
        UIApplication.shared.open(self, options: [:], completionHandler: nil)
    }
    
}