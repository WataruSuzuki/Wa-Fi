//
//  VC+Action.swift
//  WallpaperResizer
//
//  Created by 鈴木航 on 2020/10/08.
//  Copyright © 2020 鈴木 航. All rights reserved.
//

import Foundation

extension ViewController {

    @IBAction func tapUnlockAd() {
        PurchaseService.shared.purchase(productID: ServiceKeys.UNLOCK_AD, completion: { result in
            DispatchQueue.main.async {
                self.updateAdDisplaying(result: result)
            }
        })
    }

    @IBAction func tapRestorePurchase() {        
        PurchaseService.shared.restore(productIDs: [ServiceKeys.UNLOCK_AD]) { (result) in
            DispatchQueue.main.async {
                self.updateAdDisplaying(result: result)
            }
        }
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
            
            if UIDevice.current.userInterfaceIdiom == .pad
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
    
    @IBAction func tapButtonRotateTo90(_ sender:AnyObject){
        if imageView.image != nil {
            imageView.image = rotateImageTo90(imageView.image!)
        } else {
            showInterstitalAd()
        }
    }
    
    private func rotateImageTo90(_ currentImage:UIImage) ->UIImage {
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
    
    private func updateAdDisplaying(result: Bool) {
        #if targetEnvironment(simulator)
        if let banner = bannerView {
            banner.removeFromSuperview()
            banner.isHidden = true
            bannerView = nil
        }
        #else
        purchaseButton.isHidden = result
        restoreButton.isHidden = result
        if result {
            if let banner = bannerView {
                banner.removeFromSuperview()
                banner.isHidden = true
                bannerView = nil
            }
        }
        #endif
    }
}
