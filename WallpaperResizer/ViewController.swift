//
//  ViewController.swift
//  WallpaperResizer
//
//  Created by 鈴木 航 on 2014/08/23.
//  Copyright (c) 2014年 鈴木 航. All rights reserved.
//

import UIKit
//import DJKInAppPurchase

class ViewController: UIViewController,
    //DJKInAppPurchaseDelegate,
    UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
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
    
    @IBAction func tapUnlockAd() {
        //TODO -> purchaseManager.addPaymentTransaction()
    }

    @IBAction func tapSaveButton(_ sender:AnyObject){
        if imageView.image == nil {
            showAlertError(NSLocalizedString("no_photo", comment: ""))
        } else {
            let x = CGFloat(self.view.frame.size.width / 2 - (progressView?.frame.size.width)! / 2)
            let y = CGFloat(self.view.frame.size.height / 2 - (progressView?.frame.size.height)! / 2)
            progressView?.frame = CGRect(x: x, y: y, width: (progressView?.frame.size.width)!, height: (progressView?.frame.size.height)!)
            
            self.view.addSubview(progressView!)
            progressView?.startAnimating()
            
            let time = DispatchTime.now() + Double(Int64(1.0)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                Thread.detachNewThreadSelector(#selector(ViewController.handleDelaySavePhoto), toTarget:self, with: nil)
            })
        }
    }
    
    @IBAction func tapOrganaizeButton(_ sender:AnyObject){
        if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
                && 8.0 <= (UIDevice.current.systemVersion as NSString).floatValue
            {
                let popOver = UIPopoverController(contentViewController: picker)
                popOver.present(from: sender as! UIBarButtonItem, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            } else {
                self.present(picker, animated: true, completion: nil)
            }
        } else {
            
            //do nothing
        }
    }
    
    @IBAction func tapTrushButton(_ sender:AnyObject){
        showConfirmDeleteActionSheet()
    }
    
    func showAlertError(_ message: String) {
        let okStr = NSLocalizedString("ok", comment: "")
        let tapAction = UIAlertAction(title: okStr, style: UIAlertAction.Style.default){
            action in
        }
        let alertController = UIAlertController(title: nil, message: message as String, preferredStyle: .alert)
        alertController.addAction(tapAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func showAlertLaunchPhotoApp() {
        let cancelStr = NSLocalizedString("not_launch_app", comment: "")
        let launchSettingStr = NSLocalizedString("launch_wallpapersetting", comment: "")
        let launchPhotoStr = NSLocalizedString("launch_photoapp", comment: "")
        let message = NSLocalizedString("save_camera_role", comment: "")
        
        showAlertControllerLaunchPhotoApp(cancelStr, launchPhotoStr: launchPhotoStr, launchSettingStr: launchSettingStr, message: message)
    }
    
    func showAlertControllerLaunchPhotoApp(_ cancelStr: String, launchPhotoStr: String, launchSettingStr: String, message: String){
        let cancelAction = UIAlertAction(title: cancelStr, style: UIAlertAction.Style.default){
            action in self.handleCancel()
        }
        let launchPhotoAction = UIAlertAction(title: launchPhotoStr, style: UIAlertAction.Style.default){
            action in self.handleLaunchPhotoApp()
        }
        let launchSettingAction = UIAlertAction(title: launchSettingStr, style: UIAlertAction.Style.default){
            action in self.handleLaunchWallpaperSetting()
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(cancelAction)
        alertController.addAction(launchPhotoAction)
        if #available(iOS 11, *) {
            //do nothing
        } else {
            alertController.addAction(launchSettingAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showConfirmDeleteActionSheet() {
        let cancelStr = NSLocalizedString("cancel", comment: "")
        let deleteStr = NSLocalizedString("delete_this", comment: "")
        
        showConfirmDeleteAlertController(cancelStr, deleteStr: deleteStr)
    }
    
    func showConfirmDeleteAlertController(_ cancelStr: String, deleteStr: String){
        let cancelAction = UIAlertAction(title: cancelStr, style: UIAlertAction.Style.cancel){
            action in self.handleCancel()
        }
        let deleteAction = UIAlertAction(title: deleteStr, style: UIAlertAction.Style.destructive){
            action in self.handleDelete()
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            alertController.popoverPresentationController?.sourceView = self.view;
            //Rectを指定する場合...
            alertController.popoverPresentationController?.sourceRect = CGRect(x: 10.0, y: self.view.frame.size.height-self.toolBar.frame.size.height, width: 50.0, height: 50.0);
            //RectではなくUIBarButtonItemを起点にする場合...
            //alertController.popoverPresentationController?.barButtonItem
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func handleCancel(){
        //do nothing
    }

    func handleDelete(){
        imageView.image = nil
        labelMsgChoosePhoto.isHidden = false
        //buttonRotateTo90.hidden = true
    }
    
    @objc func handleDelaySavePhoto() {
        DispatchQueue.main.async {
            self.saveWallpaperImage()
            self.showAlertLaunchPhotoApp()
            self.showInterstitalAd()
        }
    }
    
    func handleLaunchPhotoApp(){
        let photoAppUrl = URL(string: "photos-redirect://")
        UIApplication.shared.openURL(photoAppUrl!)
    }
    
    func handleLaunchWallpaperSetting(){
        let prefixStr: String
        if #available(iOS 10, *) {
            prefixStr = "app-Prefs"
        } else {
            prefixStr = "prefs"
        }
        let profileSettingScheme = ":root=Wallpaper"
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: prefixStr + profileSettingScheme)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string: prefixStr + profileSettingScheme)!)
        }
    }

    func rotateImageTo90(_ currentImage:UIImage) ->UIImage {
        var orientation = UIImage.Orientation.up
        
        if currentImage.imageOrientation == UIImage.Orientation.up {
            orientation = UIImage.Orientation.right
        } else if currentImage.imageOrientation == UIImage.Orientation.right {
            orientation = UIImage.Orientation.down
        } else if currentImage.imageOrientation == UIImage.Orientation.down {
            orientation = UIImage.Orientation.left
        }
        
        return UIImage(cgImage: currentImage.cgImage!, scale: currentImage.scale, orientation: orientation)
    }
    
    @IBAction func tapButtonRotateTo90(_ sender:AnyObject){
        if imageView.image != nil {
            imageView.image = rotateImageTo90(imageView.image!)
        } else {
            showInterstitalAd()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let rectValue = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.cropRect)] as! NSValue
        originalRect = rectValue.cgRectValue
        
        // original image
        var originalImage : UIImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        // cropped image
        if originalImage.imageOrientation != UIImage.Orientation.up {
            originalImage = UIImage(cgImage: originalImage.cgImage!, scale: originalImage.scale, orientation: UIImage.Orientation.up)
        }
        let imageRef : CGImage = originalImage.cgImage!.cropping(to: originalRect)!
        let croppedImage : UIImage = UIImage(cgImage: imageRef)
        
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = croppedImage;
        
        dismiss(animated: true, completion: nil)
        labelMsgChoosePhoto.isHidden = true
    }
    
    func saveWallpaperImage(){
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
    
    enum TAG_ALERTVIEW:Int{
        case launch_PHOTO_APP = 0,
        error_MSG,
        max_TAG_LAUNCH
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
