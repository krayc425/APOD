//
//  APODSettingsTableViewController.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/8.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import StoreKit

class APODSettingsTableViewController: UITableViewController {

    @IBOutlet weak var videoRatioLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
        
        versionLabel.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadRatioLabel() {
        videoRatioLabel.text = UserDefaults.standard.string(forKey: "video_ratio_description")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let alertVC = UIAlertController(title: "Choose a video ratio", message: nil, preferredStyle: .actionSheet)
            
            videoRatioArray.forEach({ tuple in
                let action = UIAlertAction(title: tuple.description, style: .default) { _ in
                    UserDefaults.standard.set(tuple.ratio, forKey: "video_ratio")
                    UserDefaults.standard.set(tuple.description, forKey: "video_ratio_description")
                    UserDefaults.standard.synchronize()
                    self.reloadRatioLabel()
                }
                action.setValue(UIColor.apod, forKey: "titleTextColor")
                alertVC.addAction(action)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            cancelAction.setValue(UIColor.apod, forKey: "titleTextColor")
            alertVC.addAction(cancelAction)
            
            if let popoverPresentationController = alertVC.popoverPresentationController {
                popoverPresentationController.permittedArrowDirections = .up
                popoverPresentationController.sourceView = tableView.cellForRow(at: indexPath)
                popoverPresentationController.sourceRect = (tableView.cellForRow(at: indexPath)?.frame)!
            }
            
            present(alertVC, animated: true, completion: nil)
        case (1, 0):
            let url = URL(string: "https://itunes.apple.com/us/app/itunes-u/id\(kAppID)?action=write-review&mt=8")!
            print(UIDevice.current.systemVersion)
            if Float(UIDevice.current.systemVersion.split(separator: ".")[0])! >= 10.0 {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
            break
        default:
            break
        }
    }

}
