//
//  APODDetailViewController.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/7.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import WebKit
import Kingfisher
import SVProgressHUD
import Photos

class APODDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    var apodModel: APODModel?
    
    @IBOutlet weak var hdButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var mainImageView: UIImageView!
    lazy var webView: WKWebView = {
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.allowsPictureInPictureMediaPlayback = true
        let wkView = WKWebView(frame: mainImageView.frame, configuration: webViewConfig)
        wkView.isOpaque = false
        return wkView
    }()
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let model = self.apodModel,
            let type = model.media_type,
            let date = model.date {
            
            self.titleLabel.text = self.apodModel?.title
            
            self.navigationItem.title = apodDateFormatter.string(from: date)
            
            let pinchGesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(gestureAction(_:)))
            mainImageView.addGestureRecognizer(pinchGesture)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(gestureAction(_:)))
            mainImageView.addGestureRecognizer(panGesture)
            
            switch type {
            case .image:
                
                mainImageView.isHidden = false
                hdButton.isHidden = false
                saveButton.isHidden = false
                
                mainImageView.kf.setImage(with: (model.url)!, placeholder: nil, options: nil, progressBlock: { (current, total) in
                    SVProgressHUD.showProgress(Float(current) / Float(total))
                }, completionHandler: { (image, error, cacheType, url) in
                    let imageViewHeight = kScreenWidth / (image?.size.width ?? 1.0) * (image?.size.height ?? 1.0)
                    
                    self.mainImageView.frame = CGRect(x: self.mainImageView.frame.origin.x,
                                                      y: self.mainImageView.frame.origin.y,
                                                      width: kScreenWidth,
                                                      height: imageViewHeight)
                    SVProgressHUD.dismiss()
                })
            case .video:
                mainImageView.isHidden = true
                hdButton.isHidden = true
                saveButton.isHidden = true
                
                webView.frame = CGRect(x: self.mainImageView.frame.origin.x,
                                            y: self.mainImageView.frame.origin.y,
                                            width: kScreenWidth,
                                            height: kScreenWidth / 16.0 * 9.0)
                webView.load(URLRequest(url: self.apodModel!.url!))
                view.addSubview(self.webView)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func gestureAction(_ sender: UIGestureRecognizer) {
        if let model = apodModel,
            let type = model.media_type {
            guard type == .image else {
                return
            }
            if sender.state == .began || sender.state == .changed {
                if sender is UIPanGestureRecognizer {
                    let gesture: UIPanGestureRecognizer = sender as! UIPanGestureRecognizer
                    let translation = gesture.translation(in: mainImageView.superview)
                    mainImageView.center = CGPoint(x: mainImageView.center.x + translation.x,
                                                   y: mainImageView.center.y + translation.y)
                    gesture.setTranslation(.zero, in: mainImageView.superview)
                } else if sender is UIPinchGestureRecognizer {
                    let gesture: UIPinchGestureRecognizer = sender as! UIPinchGestureRecognizer
                    mainImageView.transform = mainImageView.transform.scaledBy(x: gesture.scale,
                                                                               y: gesture.scale)
                    gesture.scale = 1
                }
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func loadHDAction(_ sender: UIButton) {
        if let model = apodModel,
            let type = model.media_type, type == .image,
            let hdurl = model.hdurl {
            SVProgressHUD.show(withStatus: "Loading")
            self.mainImageView.kf.setImage(with: hdurl, placeholder: nil, options: nil, progressBlock: { (current, total) in
                SVProgressHUD.showProgress(Float(current) / Float(total))
            }, completionHandler: { (image, error, cacheType, url) in
                let imageViewHeight = kScreenWidth / (image?.size.width ?? 1.0) * (image?.size.height ?? 1.0)
                
                self.mainImageView.frame = CGRect(x: self.mainImageView.frame.origin.x,
                                                  y: self.mainImageView.frame.origin.y,
                                                  width: kScreenWidth,
                                                  height: imageViewHeight)
                SVProgressHUD.dismiss()
            })
        }
    }
    
    @IBAction func saveToAlbumAction(_ sender: UIButton) {
        if let image = mainImageView.image {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { (isSuccess: Bool, error: Error?) in
                if isSuccess {
                    SVProgressHUD.showSuccess(withStatus: "Save successfully")
                } else{
                    SVProgressHUD.showError(withStatus: "Save failed\n\(error!.localizedDescription)")
                }
                SVProgressHUD.dismiss(withDelay: 2.0)
            }
        }
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        if let model = apodModel,
            let type = model.media_type {
            switch type {
            case .image:
                let imageToShare = [mainImageView.image!]
                let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            case .video:
                let urlToShre = [model.url!]
                let activityViewController = UIActivityViewController(activityItems: urlToShre, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        
    }
    
}
