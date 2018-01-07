//
//  APODFavoriteCollectionViewCell.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/7.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit

class APODFavoriteCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configure(with model: APODModel) {
        mainImageView.kf.setImage(with: (model.url)!, placeholder: nil, options: nil, progressBlock: { (current, total) in
        }, completionHandler: { (image, error, cacheType, url) in
            print("Finished")
        })
        titleLabel.text = model.title
        dateLabel.text = apodDateFormatter.string(from: model.date!)
    }
    
}
