//
//  VKAuthorizationManager.swift
//  RCG Personnel
//
//  Created by iFoxxy on 22.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import VK_ios_sdk

class VKAuthenticationHandler : BaseAuthenticationHandler, VKSdkDelegate, VKSdkUIDelegate {
    
    let vkAppID = "5429703"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    
    func performAuthentication(parentViewController: UIViewController?) {
        self.parentViewController = parentViewController
        let instance = VKSdk.initializeWithAppId(self.vkAppID)
        instance.registerDelegate(self)
        instance.uiDelegate = self
        
        if VKSdk.isLoggedIn()
        {
            VKSdk.wakeUpSession([VK_PER_EMAIL,VK_PER_FRIENDS,VK_PER_WALL]) { (state: VKAuthorizationState, error: NSError!) -> Void in
            if state == .Authorized {
                print(VKSdk.isLoggedIn())
                NSLog("%@","Allready authorized, dismissing parent view controller")
                parentViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        else {
            if VKSdk.vkAppMayExists() {
                VKSdk.authorize([VK_PER_EMAIL,VK_PER_FRIENDS,VK_PER_WALL,VK_PER_OFFLINE])
            } else {
                VKSdk.authorize([VK_PER_EMAIL,VK_PER_FRIENDS,VK_PER_WALL, VK_PER_OFFLINE])
            }
            
            print(VKSdk.isLoggedIn())
            //parentViewController?.dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
    
    func performLogoff() {
        VKSdk.forceLogout()
    }
    
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        if let usertoken = result.token {
            
            //print(result.user.id)
            print(VKSdk.isLoggedIn())//Okay
            print(result.token.accessToken)
        }
        else if let error = result.error {
            if (error.vkError.errorCode == -102) {
                //Canceled
                NSLog("%@","Authroization failed: VK Api cancelled")
            }
            else {
                NSLog("%@","Authorization failed: network error, or user denied authentication prompt in app")
            }
        }
    }
    
    
    func vkSdkUserAuthorizationFailed() {
        //Вызывается, когда пользователь деавторизовал приложение на сайте или сменил пароль: https://github.com/VKCOM/vk-ios-sdk/issues/299
        
    }
    
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        parentViewController?.presentViewController(controller, animated: true, completion: nil)
        print(VKSdk.isLoggedIn())
    }
    
    func vkSdkAuthorizationStateUpdatedWithResult(result: VKAuthorizationResult!) {
        if result.state == .Authorized {
            self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
        let vc = VKCaptchaViewController.captchaControllerWithError(captchaError)
        vc.presentIn(parentViewController)
    }
    
    func vkSdkAccessTokenUpdated(newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        print(newToken?.accessToken)
        print(oldToken?.accessToken)
    }
}
