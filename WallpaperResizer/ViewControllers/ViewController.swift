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
    @IBOutlet weak var restoreButton: UIButton!

    var originalRect: CGRect!
        
    let progressView = MGFinderView(squareSide: 150, color: UIColor.orange)
    var bannerView: UIView?
    
    private func setupAdMob() {
        PurchaseService.shared.confirmPersonalizedConsent(
            publisherIds: [ServiceKeys.ADMOB_PUB_ID],
            productId: ServiceKeys.UNLOCK_AD,
            privacyPolicyUrl: AppDelegate.privacyPolicyUrl, completion: { (confirmed) in
                if confirmed && !self.purchaseButton.isHidden {
                    PurchaseService.shared.loadInterstitial(unitId: ServiceKeys.INTERSTITIAL)
                    let bannerId = UIDevice.current.userInterfaceIdiom == .pad
                        ? ServiceKeys.BANNER_PAD
                        : ServiceKeys.BANNER_PHONE
                    
                    if self.bannerView == nil {
                        let banner = PurchaseService.shared.bannerView(unitId: bannerId, rootViewController: self)
                        self.view.addSubview(banner)
                        banner.autoPinEdge(.bottom, to: .top, of: self.toolBar)
                        banner.autoAlignAxis(toSuperviewAxis: .vertical)
                        self.bannerView = banner
                    }
                }
            }
        )
    }
    
    override func viewDidLoad() {
        setupAdMob()
        
        super.viewDidLoad()
        
        imageView.layer.borderColor = UIColor.orange.cgColor
        imageView.layer.borderWidth = 3.0
        
        labelMsgChoosePhoto.text = NSLocalizedString("choose_photo", comment: "")
        buttonRotateTo90.title = NSLocalizedString("rotate_90", comment: "")
        purchaseButton.setTitle("unlock_ad".localized, for: .normal)
        restoreButton.setTitle("restore".localized, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let isPurchased = PurchaseService.shared.isPurchased(productID: ServiceKeys.UNLOCK_AD)
        if !isPurchased {
            setupAdMob()
        }
        purchaseButton.isHidden = isPurchased
        restoreButton.isHidden = isPurchased
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        showAlertError(NSLocalizedString("maybe_unneed", comment: ""))
    }
    
    @objc func handleDelaySavePhoto() {
        DispatchQueue.main.async {
            self.showInterstitalAd()
            self.saveWallpaperImage()
            self.showAlertLaunchPhotoApp()
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
}
