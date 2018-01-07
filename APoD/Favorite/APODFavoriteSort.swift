//
//  APODFavoriteSort.swift
//  APoD
//
//  Created by 宋 奎熹 on 2018/1/7.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

import Foundation

typealias APODFavoriteSortDescriptor = (APODModel, APODModel) -> Bool

private let dateAscendingSortDescriptor: APODFavoriteSortDescriptor = { model1, model2 in
    (model1.date?.timeIntervalSince1970 ?? 0.0) < (model2.date?.timeIntervalSince1970 ?? 0.0)
}
private let dateDescendingSortDescriptor: APODFavoriteSortDescriptor = { model1, model2 in
    (model1.date?.timeIntervalSince1970 ?? 0.0) > (model2.date?.timeIntervalSince1970 ?? 0.0)
}

enum APODFavoriteSort: Int {
    
    case dateAscending      = 0
    case dateDescending     = 1
    
    func getSortDescriptor() -> APODFavoriteSortDescriptor {
        switch self {
        case .dateAscending:
            return dateAscendingSortDescriptor
        case .dateDescending:
            return dateDescendingSortDescriptor
        }
    }
    
}
