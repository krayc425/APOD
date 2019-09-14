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
        UIApplication.shared.open(self, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
