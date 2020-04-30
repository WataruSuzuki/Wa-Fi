//
//  AppDelegate.swift
//  WallpaperResizer
//
//  Created by 鈴木 航 on 2014/08/23.
//  Copyright (c) 2014年 鈴木 航. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //static let termsUrl = "https://watarusuzuki.github.io/Wa-Fi/terms.html"
    static let privacyPolicyUrl = "https://watarusuzuki.github.io/Wa-Fi/PRIVACY_POLICY.html"
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //Note that completeTransactions() should only be called once in your code
        PurchaseService.shared.completeTransactions()
                
        return true
    }
}

