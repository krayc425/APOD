//
//  APODInfoTableViewController.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/6.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import Kingfisher
import SVProgressHUD

class APODInfoTableViewController: UITableViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    private var imageViewHeight: CGFloat = 100.0
    
    private var currentDate: Date = Date() {
        didSet {
            self.navigationItem.title = apodDateFormatter.string(from: currentDate)
        }
    }
    
    var apodModel: APODModel? {
        didSet {
            if apodModel != nil {
                DispatchQueue.main.async {
                    if self.apodModel!.media_type == APODMediaType.image {
                        self.mainImageView.kf.setImage(with: (self.apodModel!.url)!, placeholder: nil, options: nil, progressBlock: { (current, total) in
                            SVProgressHUD.showProgress(Float(current) / Float(total))
                        }, completionHandler: { (image, error, cacheType, url) in
                            self.imageViewHeight = kScreenWidth / (image?.size.width ?? 1.0) * (image?.size.height ?? 1.0)
                            self.mainImageView.frame = CGRect(x: self.mainImageView.frame.origin.x,
                                                              y: self.mainImageView.frame.origin.y,
                                                              width: kScreenWidth,
                                                              height: self.imageViewHeight)
                            SVProgressHUD.dismiss()
                            self.tableView.reloadData()
                        })
                    } else {
                        SVProgressHUD.dismiss()
                        print("Sorry, a video")
                    }
                    self.titleLabel.text = self.apodModel!.title
                    self.explanationLabel.text = self.apodModel!.explanation
                    self.copyrightLabel.text = self.apodModel!.copyright
                }
            } else {
                self.mainImageView.image = UIImage()
                self.titleLabel.text = ""
                self.copyrightLabel.text = ""
                self.explanationLabel.text = ""
                self.favoriteBarButtonItem.image = #imageLiteral(resourceName: "heart")
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let bgView = UIView(frame: tableView.bounds)
        bgView.backgroundColor = UIColor.apod
        tableView.backgroundView = bgView
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeLeftGesture.direction = .left
        tableView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRightGesture.direction = .right
        tableView.addGestureRecognizer(swipeRightGesture)
        
        loadModel(on: Date())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.left:
            loadModel(on: currentDate.addingTimeInterval(24 * 60 * 60))
        case UISwipeGestureRecognizerDirection.right:
            loadModel(on: currentDate.addingTimeInterval(-24 * 60 * 60))
        default:
            return
        }
    }
    
    func loadModel(on date: Date) {
        self.apodModel = nil
        self.currentDate = date
        
        if let model = APODHelper.shared.getFavoriteModel(on: date) {
            self.favoriteBarButtonItem.image = #imageLiteral(resourceName: "heart_full")
            self.apodModel = model
        } else {
            self.favoriteBarButtonItem.image = #imageLiteral(resourceName: "heart")
            SVProgressHUD.show(withStatus: "Loading")
            DispatchQueue.global().async {
                APODHelper.shared.getAPODInfo(on: date) { model in
                    self.apodModel = model
                }
            }
        }
    }
    
    @IBAction func favoriteAction(_ sender: UIBarButtonItem) {
        if let model = self.apodModel {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            
            if let _ = APODHelper.shared.getFavoriteModel(on: model.date!) {
                favoriteBarButtonItem.image = #imageLiteral(resourceName: "heart")
                
                APODHelper.shared.removeFavorite(model: model)
            } else {
                favoriteBarButtonItem.image = #imageLiteral(resourceName: "heart_full")
                
                APODHelper.shared.addFavorite(model: model)
            }
        }
    }

    @IBAction func calendarAction(_ sender: UIBarButtonItem) {
        let alertVC = UIAlertController(title: "Choose a date", message: nil, preferredStyle: .actionSheet)
        alertVC.view.addSubview(apodDatePicker)
        alertVC.view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 10)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.loadModel(on: apodDatePicker.date)
        }
        okAction.setValue(UIColor.apod, forKey: "titleTextColor")
        alertVC.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.apod, forKey: "titleTextColor")
        alertVC.addAction(cancelAction)
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alertVC.view,
                                                           attribute: .height,
                                                           relatedBy: .equal,
                                                           toItem: nil,
                                                           attribute: .notAnAttribute,
                                                           multiplier: 1,
                                                           constant: apodDatePicker.frame.height + 120)
        alertVC.view.addConstraint(height)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return imageViewHeight
        default:
            return UITableViewAutomaticDimension
        }
    }
    
}
