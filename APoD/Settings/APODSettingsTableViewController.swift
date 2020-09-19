//
//  APODSettingsTableViewController.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/8.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import StoreKit
import AcknowList

class APODSettingsTableViewController: UITableViewController {

    @IBOutlet weak var videoRatioLabel: UILabel?
    @IBOutlet weak var versionLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SKStoreReviewController.requestReview()
        
        versionLabel?.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    func reloadRatioLabel() {
        videoRatioLabel?.text = kUserDefaults.string(forKey: "video_ratio_description")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 5
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let alertVC = UIAlertController(title: NSLocalizedString("Choose a video ratio", comment: ""), message: nil, preferredStyle: .actionSheet)
            
            videoRatioArray.forEach({ tuple in
                let action = UIAlertAction(title: tuple.description, style: .default) { _ in
                    kUserDefaults.set(tuple.ratio, forKey: "video_ratio")
                    kUserDefaults.set(tuple.description, forKey: "video_ratio_description")
                    kUserDefaults.synchronize()
                    self.reloadRatioLabel()
                }
                action.setValue(UIColor.apodReversed, forKey: "titleTextColor")
                alertVC.addAction(action)
            })
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            cancelAction.setValue(UIColor.apodReversed, forKey: "titleTextColor")
            alertVC.addAction(cancelAction)
            
            if let popoverPresentationController = alertVC.popoverPresentationController {
                popoverPresentationController.permittedArrowDirections = []
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                                  y: self.view.bounds.midY,
                                                                  width: 0,
                                                                  height: 0)
            }
            
            present(alertVC, animated: true, completion: nil)
        case (1, 0):
            let url = URL(string: "https://itunes.apple.com/us/app/itunes-u/id\(kAppID)?action=write-review&mt=8")!
            url.open()
        case (1, 1):
            let activityViewController = UIActivityViewController(activityItems: [UIImage(named: "logo")!, "APOD by Kuixi Song", URL(string: kAppItunesLink)!],
                                                                  applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        case (1, 2):
            let url = URL(string: "sms:krayc425@gmail.com")!
            url.open()
        case (1, 3):
            let viewController = AcknowListViewController()
            navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }

}
