//
//  StringExtension.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/23.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import Foundation

extension String {
    
    func substring(_ from: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        return String(self[start ..< endIndex])
    }
    
}
