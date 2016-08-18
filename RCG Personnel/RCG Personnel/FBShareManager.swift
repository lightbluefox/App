//
//  FBShareManager.swift
//  RCG Personnel
//
//  Created by iFoxxy on 17.08.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation
import FBSDKShareKit

final class FBShareManager: BaseShareManager, FBSDKSharingDelegate {
    
    let hudManager = HUDManager()
    
    func share(title: String, description: String, url: NSURL, imageURL: NSURL?) {
        let shareDialog = FBSDKShareDialog()
        let content = FBSDKShareLinkContent()
        
        content.contentTitle = title
        content.contentDescription = description
        content.contentURL = url
        if imageURL != nil {
            content.imageURL = imageURL
        }
        shareDialog.shareContent = content
        shareDialog.fromViewController = parentViewController
        shareDialog.delegate = self
        
        shareDialog.mode = .Native
        
        if !shareDialog.canShow() {
            shareDialog.mode = .FeedBrowser
        }
        
        shareDialog.show()
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        NSLog("Cancelled sharing to FB")
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        hudManager.parentViewController = self.parentViewController
        hudManager.showHUD("Не удалось поделиться :(", details: error.description, type: .Failure)
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        NSLog("Sharing to FB completed with some result.")
    }
}