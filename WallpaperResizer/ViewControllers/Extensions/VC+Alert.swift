//
//  VC+Alert.swift
//  WallpaperResizer
//
//  Created by 鈴木航 on 2020/10/08.
//  Copyright © 2020 鈴木 航. All rights reserved.
//

import Foundation

extension ViewController {

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
        
        let cancelAction = UIAlertAction(title: cancelStr, style: .cancel, handler: nil)
        let launchPhotoAction = UIAlertAction(title: launchPhotoStr, style: .default){
            action in self.handleLaunchPhotoApp()
        }
        let launchSettingAction = UIAlertAction(title: launchSettingStr, style: .default){
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
        
//        showConfirmDeleteAlertController(cancelStr, deleteStr: deleteStr)
//    }
//    
//    func showConfirmDeleteAlertController(_ cancelStr: String, deleteStr: String){
        let cancelAction = UIAlertAction(title: cancelStr, style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: deleteStr, style: .destructive){
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
    
    private func handleLaunchPhotoApp(){
        let photoAppUrl = URL(string: "photos-redirect://")
        UIApplication.shared.openURL(photoAppUrl!)
    }
    
    private func handleLaunchWallpaperSetting(){
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

    private func handleDelete() {
        imageView.image = nil
        labelMsgChoosePhoto.isHidden = false
        //buttonRotateTo90.hidden = true
    }
    
}
