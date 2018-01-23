//
//  TodayViewController.swift
//  APoDWidget
//
//  Created by 宋 奎熹 on 2018/1/23.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import NotificationCenter
import Kingfisher

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var imageViewArray: [UIImageView]! {
        didSet {
            imageViewArray.forEach {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
                $0.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    private var modelArray: [APODModel] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view {
            let tag = imageView.tag
            let model = modelArray[tag]
            self.extensionContext?.open(URL(string: "apodscheme://widgetopen?date=\(apodDateFormatter.string(from: model.date!))")!, completionHandler: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        modelArray.removeAll()
        
        let favoriteArray = APODCacheHelper.shared.getFavoriteModels()!
        let end = favoriteArray.count < imageViewArray.count ? favoriteArray.count : imageViewArray.count
        var randomDateIndexes: [Int] = []
        for _ in 0..<end {
            let i = Int(arc4random()) % end
            while randomDateIndexes.contains(i) && favoriteArray[i].media_type! == .image {
                
            }
            randomDateIndexes.append(i)
            modelArray.append(favoriteArray[i])
        }
        
        setImages()
    }
    
    func setImages() {
        for i in 0..<modelArray.count {
            imageViewArray[i].kf.setImage(with: modelArray[i].url, placeholder: #imageLiteral(resourceName: "logo"), options: nil, progressBlock: { (current, total) in
                print(current, total)
            }, completionHandler: { (_, _, _, _) in
            
            })
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
