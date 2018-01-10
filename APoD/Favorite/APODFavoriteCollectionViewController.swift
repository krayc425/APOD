//
//  APODFavoriteCollectionViewController.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/7.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import UIKit
import SimpleImageViewer
import DZNEmptyDataSet

private let reuseIdentifier = "APODFavoriteCollectionViewCell"

class APODFavoriteCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var sortBarButtonItem: UIBarButtonItem!
    
    private var animatedCellIndexs: [Int] = []
    
    private var favoriteModels: [APODModel] = [] {
        didSet {
            animatedCellIndexs.removeAll()
            collectionView?.reloadData()
        }
    }

    private var sortType: APODFavoriteSort = APODFavoriteSort(rawValue: UserDefaults.standard.integer(forKey: "favorite_sort"))! {
        didSet {
            favoriteModels.sort(by: sortType.getSortDescriptor())
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.emptyDataSetSource = self
        collectionView?.emptyDataSetDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let models = APODHelper.shared.getFavoriteModels() {
            self.favoriteModels = models.sorted(by: sortType.getSortDescriptor())
        }
        
        self.navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func sortAction(_ sender: UIBarButtonItem) {
        let alertVC = UIAlertController(title: NSLocalizedString("Choose a sort type", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        let dateAscendingAction = UIAlertAction(title: NSLocalizedString("Date Ascending", comment: ""), style: .default) { _ in
            self.sortType = APODFavoriteSort.dateAscending
            UserDefaults.standard.set(APODFavoriteSort.dateAscending.rawValue, forKey: "favorite_sort")
            UserDefaults.standard.synchronize()
        }
        dateAscendingAction.setValue(UIColor.apod, forKey: "titleTextColor")
        alertVC.addAction(dateAscendingAction)
        
        let dateDescendingAction = UIAlertAction(title: NSLocalizedString("Date Descending", comment: ""), style: .default) { _ in
            self.sortType = APODFavoriteSort.dateDescending
            UserDefaults.standard.set(APODFavoriteSort.dateDescending.rawValue, forKey: "favorite_sort")
            UserDefaults.standard.synchronize()
        }
        dateDescendingAction.setValue(UIColor.apod, forKey: "titleTextColor")
        alertVC.addAction(dateDescendingAction)
        
        let titleAscendingAction = UIAlertAction(title: NSLocalizedString("Title Ascending", comment: ""), style: .default) { _ in
            self.sortType = APODFavoriteSort.titleAscending
            UserDefaults.standard.set(APODFavoriteSort.titleAscending.rawValue, forKey: "favorite_sort")
            UserDefaults.standard.synchronize()
        }
        titleAscendingAction.setValue(UIColor.apod, forKey: "titleTextColor")
        alertVC.addAction(titleAscendingAction)
        
        let titleDescendingAction = UIAlertAction(title: NSLocalizedString("Title Descending", comment: ""), style: .default) { _ in
            self.sortType = APODFavoriteSort.titleDescending
            UserDefaults.standard.set(APODFavoriteSort.titleDescending.rawValue, forKey: "favorite_sort")
            UserDefaults.standard.synchronize()
        }
        titleDescendingAction.setValue(UIColor.apod, forKey: "titleTextColor")
        alertVC.addAction(titleDescendingAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.apod, forKey: "titleTextColor")
        alertVC.addAction(cancelAction)
        
        if let popoverPresentationController = alertVC.popoverPresentationController {
            popoverPresentationController.barButtonItem = sortBarButtonItem
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = .zero
        }
        
        present(alertVC, animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteModels.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! APODFavoriteCollectionViewCell
    
        cell.configure(with: favoriteModels[indexPath.row])
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! APODFavoriteCollectionViewCell
        let configuration = ImageViewerConfiguration { config in
            config.imageView = cell.mainImageView
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (kScreenWidth - 30) / 2.0, height: (kScreenWidth - 30) / 2.0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if animatedCellIndexs.contains(indexPath.row) {
            return
        }
        cell.alpha = 0.0
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            cell.alpha = 1.0
        }) { _ in
            self.animatedCellIndexs.append(indexPath.row)
        }
    }

}

extension APODFavoriteCollectionViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "logo_grey")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributedString = NSAttributedString(string: NSLocalizedString("Nothing yet", comment: ""),
                                                  attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18.0)])
        return attributedString
    }

}
