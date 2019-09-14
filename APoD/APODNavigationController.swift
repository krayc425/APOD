//
//  APODNavigationController.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/6.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit

class APODNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.delegate = self
        
        self.navigationBar.setValue(true, forKey: "hidesShadow")
        
        self.navigationBar.prefersLargeTitles = true
        let dict:[NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationBar.largeTitleTextAttributes = dict
        
        self.view.backgroundColor = UIColor.apod
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count >= 1 {
            let button = UIButton(type: .custom)
            button.bounds = CGRect(x: 0, y: 0, width: 100, height: 21)
            button.setImage(#imageLiteral(resourceName: "nav_back"), for: UIControl.State.normal)
            button.setImage(#imageLiteral(resourceName: "nav_back"), for: UIControl.State.highlighted)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets.zero
            button.addTarget(self, action: #selector(back), for: UIControl.Event.touchUpInside)
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    @objc func back() {
        self.popViewController(animated: true)
    }
    
}

