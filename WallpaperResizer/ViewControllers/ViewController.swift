//
//  ViewController.swift
//  WallpaperResizer
//
//  Created by 鈴木 航 on 2014/08/23.
//  Copyright (c) 2014年 鈴木 航. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelMsgChoosePhoto: UILabel!
    @IBOutlet weak var buttonRotateTo90: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var purchaseButton: UIButton!
    
    var originalRect: CGRect!
        
    let progressView = MGFinderView(squareSide: 150, color: UIColor.orange)
    var bannerView: UIView!
    
    
    // TODO: KeyInAppPurchase.UNLOCK_AD
    private func setupAdMob() {
        PurchaseService.shared.confirmPersonalizedConsent(publisherIds: ["your_pub_id"], productId: "your_product_id", privacyPolicyUrl: AppDelegate.privacyPolicyUrl, completion: { (confirmed) in
            if confirmed {
                PurchaseService.shared.loadReward(unitId: "your_reward_unit_id")
                self.bannerView = PurchaseService.shared.bannerView(unitId: "your_banner_unit_id", rootViewController: self)
            }
        })
    }
    
    override func viewDidLoad() {
        setupAdMob()
        
        super.viewDidLoad()
        
        imageView.layer.borderColor = UIColor.orange.cgColor
        //imageView.layer.borderColor = UIColor(red: 0, green: 0.392, blue: 0, alpha: 1.0).CGColor
        imageView.layer.borderWidth = 3.0
        
        labelMsgChoosePhoto.text = NSLocalizedString("choose_photo", comment: "")
        buttonRotateTo90.title = NSLocalizedString("rotate_90", comment: "")
        purchaseButton.setTitle(NSLocalizedString("unlock_ad", comment: ""), for: .normal)
    }
    
    //TODO: KeyIdAdMob.BANNER_PAD
    //TODO: KeyIdAdMob.BANNER_PHONE
    //TODO: KeyIdAdMob.INTERSTITIAL
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if DJKKeychainManager().isPurchased(Bundle.main.bundleIdentifier!, withValueKey: ) {
//            purchaseButton.isHidden = true
//        } else {
            purchaseButton.isHidden = false
//            if currentPersonalizedAdConsentStatus != .unknown {
//                setupAdMob()
//            }
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        showAlertError(NSLocalizedString("maybe_unneed", comment: ""))
    }
    
    @objc func handleDelaySavePhoto() {
        DispatchQueue.main.async {
            self.saveWallpaperImage()
            self.showAlertLaunchPhotoApp()
            self.showInterstitalAd()
        }
    }
    
    private func saveWallpaperImage(){
        var backgroundIMG:UIImage = UIImage(named:"background.png")!;
        let foregroundIMG:UIImage = imageView.image!;
        let widthBG = foregroundIMG.size.width*2
        let heightBG = foregroundIMG.size.height*2
        
        UIGraphicsBeginImageContext(CGSize(width: widthBG, height: heightBG));
        backgroundIMG.draw(in: CGRect(x: 0, y: 0, width: widthBG, height: heightBG))
        backgroundIMG = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: widthBG, height: heightBG), false, 0.0)
        //UIGraphicsBeginImageContextWithOptions(CGSizeMake(backgroundIMG.size.width, backgroundIMG.size.height), false, 0.0)
        
        backgroundIMG.draw(at: CGPoint(x: 0, y: 0))
        foregroundIMG.draw(at: CGPoint(
            x: widthBG/2 - foregroundIMG.size.width/2,
            y: heightBG/2 - foregroundIMG.size.height/2))
        
        let newIMG = UIGraphicsGetImageFromCurrentImageContext()
        
        UIImageWriteToSavedPhotosAlbum(newIMG!, self, nil, nil)
        UIGraphicsEndImageContext()
        
        progressView?.removeFromSuperview()
    }
    
    func showInterstitalAd() {
        PurchaseService.shared.showReward(rootViewController: self)
    }
    
    func removeAdMob() {
        //TODO: admobBannerView.removeFromSuperview()
    }
    
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
