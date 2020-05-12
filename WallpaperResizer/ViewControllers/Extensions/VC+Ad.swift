//
//  VC+Ad.swift
//  WallpaperResizer
//
//  Created by 鈴木航 on 2020/10/09.
//  Copyright © 2020 鈴木 航. All rights reserved.
//

import Foundation

extension ViewController {
    
    func showInterstitalAd() {
        guard !PurchaseService.shared.isPurchased(productID: ServiceKeys.UNLOCK_AD) else {
            return
        }
        PurchaseService.shared.showInterstitial(rootViewController: self)
    }
}
