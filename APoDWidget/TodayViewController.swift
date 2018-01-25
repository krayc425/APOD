//
//  TodayViewController.swift
//  APoDWidget
//
//  Created by 宋 奎熹 on 2018/1/23.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import NotificationCenter

typealias APODWidgetDictPair = (date: String, imageData: Data)

private let kUIViewAnimationDuration = 0.05

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var noDataLabel: UILabel! {
        didSet {
            noDataLabel.text = NSLocalizedString("Nothing yet", comment: "")
        }
    }
    
    @IBOutlet var imageViewArray: [UIImageView]! {
        didSet {
            imageViewArray.forEach {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
                $0.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    private var widgetPairs: [APODWidgetDictPair] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view {
            let tag = imageView.tag
            self.extensionContext?.open(URL(string: "apodscheme://widgetopen?date=\(widgetPairs[tag].date)")!, completionHandler: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        widgetPairs.removeAll()
        
        let favoriteArray = APODWidgetHelper.shared.getWidgetModelDict()
        let end = favoriteArray.count < imageViewArray.count ? favoriteArray.count : imageViewArray.count
        
        guard end > 0 else {
            noDataLabel.isHidden = false
            return
        }
        noDataLabel.isHidden = true
        
        var randomDateIndexes: [Int] = []
        for _ in 0..<end {
            while true {
                let i = Int(arc4random()) % favoriteArray.count
                if !randomDateIndexes.contains(i) {
                    randomDateIndexes.append(i)
                    let index = favoriteArray.index(favoriteArray.startIndex, offsetBy: i)
                    widgetPairs.append((favoriteArray.keys[index], favoriteArray.values[index]))
                    break
                }
            }
        }
        
        setImages()
    }
    
    private func setImages() {
        for i in 0..<widgetPairs.count {
            self.imageViewArray[i].image = UIImage(data: widgetPairs[i].imageData)
            self.imageViewArray[i].alpha = 0.0
            UIView.animate(withDuration: kUIViewAnimationDuration, animations: { [weak self] in
                self?.imageViewArray[i].alpha = 1.0
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
