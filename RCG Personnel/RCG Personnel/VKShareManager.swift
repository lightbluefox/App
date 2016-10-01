//
//  VKShareManager.swift
//  RCG Personnel
//
//  Created by iFoxxy on 15.08.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import VK_ios_sdk

final class VKShareManager: BaseShareManager, VKSdkDelegate {
    let vkAppID = "5429703"
    
    
    func share(text: String, image: UIImage?, url: NSURL, urlTitle: String) {
        let instance = VKSdk.initializeWithAppId(self.vkAppID)
        instance.registerDelegate(self)
        
        let shareDialogController = VKShareDialogController()
        
        let params = VKImageParameters()
        if image != nil {
            let image = VKUploadImage(image: image, andParams: params)
            shareDialogController.uploadImages = [image]
        }
        
        shareDialogController.text = text
        shareDialogController.shareLink = VKShareLink(title: urlTitle, link: url)
        shareDialogController.completionHandler = {(controlelr: VKShareDialogController!, result: VKShareDialogControllerResult!) -> Void in
            self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        parentViewController?.presentViewController(shareDialogController, animated: true, completion: nil)
    }
    
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        print("Authorization finished with result: \(result)")
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("Authorization failed")
    }
}
