//
//  VC+ImagePicker.swift
//  WallpaperResizer
//
//  Created by 鈴木航 on 2020/10/08.
//  Copyright © 2020 鈴木 航. All rights reserved.
//

import Foundation

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let rectValue = info[UIImagePickerController.InfoKey.cropRect] as? NSValue else {
            showAlertError("(・A・)")
            return
        }
        originalRect = rectValue.cgRectValue

        guard let originalImage = originalImage(image: info[UIImagePickerController.InfoKey.originalImage] as? UIImage),
              let cgImage = originalImage.cgImage else {
            showAlertError("(・A・)")
            return
        }
        
        
        let imageRef = cgImage.cropping(to: originalRect)!
        let croppedImage : UIImage = UIImage(cgImage: imageRef)
        
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = croppedImage;
        
        dismiss(animated: true, completion: nil)
        labelMsgChoosePhoto.isHidden = true
    }
    
    private func originalImage(image: UIImage?) -> UIImage? {
        guard let originalImage = image else {
            return nil
        }
        if originalImage.imageOrientation == UIImage.Orientation.up {
            return originalImage
        }
        
        // cropped image
        guard let cgImage = originalImage.cgImage else { return nil }
        return UIImage(cgImage: cgImage, scale: originalImage.scale, orientation: UIImage.Orientation.up)
    }
}
