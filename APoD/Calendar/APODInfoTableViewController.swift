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
import WebKit
import Alamofire
import Photos
import SimpleImageViewer
import DZNEmptyDataSet
import AVFoundation

class APODInfoTableViewController: UITableViewController {
    
    private var animatedCellIndexs: [Int] = []
    
    @IBOutlet weak var mainImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var explanationTextView: UITextView?
    @IBOutlet weak var copyrightLabel: UILabel?
    lazy var webView: WKWebView = {
        guard let imageView = mainImageView else {
            return WKWebView()
        }
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.allowsPictureInPictureMediaPlayback = true
        let wkView = WKWebView(frame: imageView.frame, configuration: webViewConfig)
        wkView.isOpaque = false
        return wkView
    }()
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem?
    @IBOutlet weak var calendarBarButtonItem: UIBarButtonItem?
    @IBOutlet weak var voiceBarButtonItem: UIBarButtonItem?
    
    @IBOutlet weak var hdButton: UIButton?
    @IBOutlet weak var saveButton: UIButton?
    @IBOutlet weak var shareButton: UIButton?
    
    private lazy var synthesizer: AVSpeechSynthesizer = {
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        synthesizer.usesApplicationAudioSession = false
        return synthesizer
    }()
    
    private var imageViewHeight: CGFloat = 100.0
    private var isLoadingFailed: Bool = false
    
    var currentDate: Date = Date() {
        didSet {
            self.navigationItem.title = apodDateFormatter.string(from: currentDate)
            loadModel(on: currentDate)
        }
    }
    
    private var apodModel: APODModel? {
        didSet {
            synthesizer.stopSpeaking(at: .immediate)
            if let apodModel = apodModel {
                APODCacheHelper.shared.cacheModel(model: apodModel)
                DispatchQueue.main.async {
                    if let date = apodModel.date {
                        if APODCacheHelper.shared.isFavoriteModel(on: date) {
                            self.favoriteBarButtonItem?.image = UIImage(systemName: "heart.fill")!
                        } else {
                            self.favoriteBarButtonItem?.image = UIImage(systemName: "heart")!
                        }
                    }
                    self.titleLabel?.text = apodModel.title
                    self.explanationTextView?.text = apodModel.explanation
                    
                    if let copyright = self.apodModel?.copyright {
                        self.copyrightLabel?.text = copyright
                    }
                    
                    if self.apodModel!.media_type == APODMediaType.image {
                        let imageResourse = ImageResource(downloadURL: (self.apodModel!.url)!,
                                                          cacheKey: apodDateFormatter.string(from: self.currentDate))
                        
                        self.mainImageView?.kf.setImage(with: imageResourse, placeholder: nil, options: nil, progressBlock: { (current, total) in
                            SVProgressHUD.showProgress(Float(current) / Float(total), status: NSLocalizedString("Loading media", comment: ""))
                        }, completionHandler: { (image, error, cacheType, url) in
                            self.mainImageView?.isHidden = false
                            self.hdButton?.isHidden = false
                            self.saveButton?.isHidden = false
                            self.shareButton?.isHidden = false
                            self.imageViewHeight = kScreenWidth / (image?.size.width ?? 1.0) * (image?.size.height ?? 1.0)
                            self.mainImageView?.frame = CGRect(x: self.mainImageView?.frame.origin.x ?? 0.0,
                                                               y: self.mainImageView?.frame.origin.y ?? 0.0,
                                                               width: kScreenWidth,
                                                               height: self.imageViewHeight)
                            
                            SVProgressHUD.dismiss()
                            self.tableView.reloadData()
                        })
                    } else if self.apodModel!.media_type == APODMediaType.video {
                        self.mainImageView?.isHidden = true
                        self.hdButton?.isHidden = true
                        self.saveButton?.isHidden = true
                        self.shareButton?.isHidden = false
                        
                        let videoRatio: CGFloat = CGFloat(kUserDefaults.float(forKey: "video_ratio"))
                        self.imageViewHeight = kScreenWidth * videoRatio
                        
                        self.webView.frame = CGRect(x: self.mainImageView?.frame.origin.x ?? 0.0,
                                                    y: self.mainImageView?.frame.origin.y ?? 0.0,
                                                    width: kScreenWidth,
                                                    height: self.imageViewHeight)
                        self.webView.load(URLRequest(url: self.apodModel!.url!))
                        self.tableView.addSubview(self.webView)
                        
                        SVProgressHUD.dismiss()
                        self.tableView.reloadData()
                    }
                }
            } else {
                self.animatedCellIndexs.removeAll()
                self.mainImageView?.isHidden = true
                
                self.webView.removeFromSuperview()
                
                self.isLoadingFailed = false
                
                self.titleLabel?.text = ""
                self.copyrightLabel?.text = ""
                self.explanationTextView?.text = ""
                self.favoriteBarButtonItem?.image = UIImage(systemName: "heart")!
                
                self.hdButton?.isHidden = true
                self.saveButton?.isHidden = true
                self.shareButton?.isHidden = true
                
                cancelNetworkRequests()
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeLeftGesture.direction = UISwipeGestureRecognizer.Direction.left
        tableView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeRightGesture.direction = UISwipeGestureRecognizer.Direction.right
        tableView.addGestureRecognizer(swipeRightGesture)
        
        for button in [hdButton, saveButton, shareButton] {
            button?.layer.cornerRadius = (button?.layer.frame.height)! / 2.0
            button?.layer.masksToBounds = true
        }
        
        currentDate = Date()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancelNetworkRequests()
    }
    
    private func cancelNetworkRequests() {
        self.mainImageView?.kf.cancelDownloadTask()
        
        Alamofire.Session.default.cancelAllRequests(completingOnQueue: DispatchQueue.global(qos: .background))
        
        SVProgressHUD.dismiss()
    }
    
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.left:
            let newDate = currentDate.addingTimeInterval(24 * 60 * 60)
            if newDate.timeIntervalSince1970 <= maximumDate.timeIntervalSince1970 {
                currentDate = newDate
            }
        case UISwipeGestureRecognizer.Direction.right:
            let newDate = currentDate.addingTimeInterval(-24 * 60 * 60)
            if newDate.timeIntervalSince1970 >= minimumDate.timeIntervalSince1970 {
                currentDate = newDate
            }
        default:
            return
        }
    }
    
    private func loadModel(on date: Date) {
        self.apodModel = nil
        
        if let model = APODCacheHelper.shared.getCacheModel(on: date) {
            self.apodModel = model
        } else {
            SVProgressHUD.show(withStatus: NSLocalizedString("Loading", comment: ""))
            DispatchQueue.global().async { [weak self] in
                APODHelper.shared.getAPODInfo(on: date) { model in
                    if model != nil {
                        self?.apodModel = model!
                    } else {
                        SVProgressHUD.showError(withStatus: NSLocalizedString("Something is wrong\non this day", comment: ""))
                        SVProgressHUD.dismiss(withDelay: 2.0, completion: {
                            self?.apodModel = nil
                            self?.isLoadingFailed = true
                            self?.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - Bar Button Actions
    
    @IBAction func voiceAction(_ sender: UIBarButtonItem) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        } else {
            guard let string = explanationTextView?.text else {
                return
            }
            let utterance = AVSpeechUtterance(string: string)
            synthesizer.speak(utterance)
        }
    }
    
    @IBAction func favoriteAction(_ sender: UIBarButtonItem) {
        if let model = self.apodModel {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            
            if APODCacheHelper.shared.isFavoriteModel(on: model.date!) {
                favoriteBarButtonItem?.image = UIImage(systemName: "heart")!
                APODCacheHelper.shared.removeFavorite(model: model)
            } else {
                favoriteBarButtonItem?.image = UIImage(systemName: "heart.fill")!
                APODCacheHelper.shared.addFavorite(model: model)
            }
        }
    }

    @IBAction func calendarAction(_ sender: UIBarButtonItem) {
        let alertVC = UIAlertController(title: NSLocalizedString("Choose a Date", comment: ""), message: nil, preferredStyle: .actionSheet)
        alertVC.view.frame = CGRect(x: 0, y: 0, width: isiPad ? 300 : kScreenWidth, height: 10)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            self.currentDate = apodDatePicker.date
        }
        okAction.setValue(UIColor.apodReversed, forKey: "titleTextColor")
        alertVC.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.apodReversed, forKey: "titleTextColor")
        alertVC.addAction(cancelAction)
        
        alertVC.view.addSubview(apodDatePicker)
        apodDatePicker.date = currentDate
        let height = NSLayoutConstraint(item: alertVC.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: apodDatePicker.frame.height + (isiPad ? 80 : 150))
        NSLayoutConstraint.activate([height])
        if !isiPad {
            apodDatePicker.center = CGPoint(x: view.center.x - 10, y: apodDatePicker.center.y)
        }
        
        if let popoverPresentationController = alertVC.popoverPresentationController {
            popoverPresentationController.barButtonItem = calendarBarButtonItem
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = .zero
        }
        
        present(alertVC, animated: true)
    }
    
    // MARK: - Button Actions
    
    @IBAction func loadHDAction(_ sender: UIButton) {
        if let model = apodModel,
            let type = model.media_type, type == .image,
            let hdurl = model.hdurl {
            SVProgressHUD.show(withStatus: NSLocalizedString("Loading", comment: ""))
            self.mainImageView?.kf.setImage(with: hdurl, placeholder: nil, options: nil, progressBlock: { (current, total) in
                SVProgressHUD.showProgress(Float(current) / Float(total), status: NSLocalizedString("Loading media", comment: ""))
            }, completionHandler: { (image, error, cacheType, url) in
                let imageViewHeight = kScreenWidth / (image?.size.width ?? 1.0) * (image?.size.height ?? 1.0)
                self.mainImageView?.frame = CGRect(x: self.mainImageView?.frame.origin.x ?? 0.0,
                                                   y: self.mainImageView?.frame.origin.y ?? 0.0,
                                                   width: kScreenWidth,
                                                   height: imageViewHeight)
                SVProgressHUD.dismiss()
            })
        }
    }
    
    @IBAction func saveToAlbumAction(_ sender: UIButton) {
        if let image = mainImageView?.image {
            guard PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized else {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    switch status {
                    case .authorized:
                        savePhoto()
                    case .denied:
                        SVProgressHUD.showError(withStatus: "Authorization denied")
                    case .restricted:
                        SVProgressHUD.showError(withStatus: "Authorization restricted")
                    case .notDetermined:
                        SVProgressHUD.showError(withStatus: "Authorization not determined")
                    case .limited:
                        break
                    @unknown default:
                        fatalError()
                    }
                    SVProgressHUD.dismiss(withDelay: 2.0)
                })
                return
            }
            func savePhoto() {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { (isSuccess: Bool, error: Error?) in
                    if isSuccess {
                        SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Save successfully", comment: ""))
                    } else{
                        SVProgressHUD.showError(withStatus: "\(NSLocalizedString("Save failed", comment: ""))\n\(error!.localizedDescription)")
                    }
                    SVProgressHUD.dismiss(withDelay: 2.0)
                }
            }
            savePhoto()
        }
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        if let model = apodModel,
            let type = model.media_type {
            switch type {
            case .image:
                if let image = mainImageView?.image,
                    let text = model.explanation {
                    let itemsToShare: [Any] = [text, image]
                    let activityViewController = UIActivityViewController(activityItems: itemsToShare,
                                                                          applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = shareButton
                    present(activityViewController, animated: true, completion: nil)
                }
            case .video:
                if let url = model.url,
                    let text = model.explanation {
                    let itemsToShare: [Any] = [url, text]
                    let activityViewController = UIActivityViewController(activityItems: itemsToShare,
                                                                          applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = shareButton
                    present(activityViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return imageViewHeight
        case 3:
            return self.apodModel?.copyright == nil ? 0.0 : UITableView.automaticDimension
        case 4:
            return self.apodModel?.copyright == nil ? 65.0 : 60.0
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if animatedCellIndexs.contains(indexPath.row) {
            return
        }
        cell.alpha = 0.0
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            cell.alpha = 1.0
        }) { _ in
            self.animatedCellIndexs.append(indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = apodModel, indexPath.row == 0 {
            let configuration = ImageViewerConfiguration { config in
                config.imageView = mainImageView
            }
            
            let imageViewerController = ImageViewerController(configuration: configuration)
            present(imageViewerController, animated: true)
        }
    }
    
}

extension APODInfoTableViewController: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        voiceBarButtonItem?.image = UIImage(systemName: "pause.fill")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        voiceBarButtonItem?.image = UIImage(systemName: "play.fill")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        voiceBarButtonItem?.image = UIImage(systemName: "play.fill")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        voiceBarButtonItem?.image = UIImage(systemName: "pause.fill")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        voiceBarButtonItem?.image = UIImage(systemName: "play.fill")
    }
    
}

extension APODInfoTableViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func emptyDataSetShouldBeForced(toDisplay scrollView: UIScrollView!) -> Bool {
        return apodModel == nil && isLoadingFailed
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributedString = NSAttributedString(string: NSLocalizedString("Try another day", comment: "") ,
                                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0, weight: .bold)])
        return attributedString
    }
    
}
