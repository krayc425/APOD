//
//  APODLanguageTableViewController.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/10.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SVProgressHUD

enum Language: String {
    
    case english = "en"
    case chinese_simplified = "zh-Hans"
    case chinese_tradition = "zh-Hant"
    
    func getDisplayString() -> String {
        switch self {
        case .english:
            return "English"
        case .chinese_simplified:
            return "简体中文"
        case .chinese_tradition:
            return "繁體中文"
        }
    }
    
}

class APODLanguageTableViewController: UITableViewController {
    
    let languageArray: [Language] = [Language.english,
                                     Language.chinese_simplified,
                                     Language.chinese_tradition]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "apodLanguageTableViewCell", for: indexPath)

        cell.textLabel?.text = languageArray[indexPath.row].getDisplayString()
        
        cell.textLabel?.textColor = .white
        
        cell.tintColor = .white
        
        if languageArray[indexPath.row].rawValue == (kUserDefaults.array(forKey: "AppleLanguages")?.first)! as! String {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        kUserDefaults.set([languageArray[indexPath.row].rawValue], forKey: "AppleLanguages")
        kUserDefaults.synchronize()
        tableView.reloadData()
        
        SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Language changed\nPlease restart the app to enable new language", comment: ""))
        SVProgressHUD.dismiss(withDelay: 2.0)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Choose a language", comment: "")
    }
    
}
