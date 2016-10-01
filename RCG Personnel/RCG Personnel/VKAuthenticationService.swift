//
//  VKAuthorizationManager.swift
//  RCG Personnel
//
//  Created by iFoxxy on 22.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import VK_ios_sdk

enum SocialAuthenticationResult {
    case Success(socialToken: String)
    case Cancelled
    case Failure(NSError?)
}

final class VKAuthenticationService: NSObject, VKSdkDelegate, VKSdkUIDelegate {
    
    var parentViewController: UIViewController?
    
    private let vkAppID = "5429703"
    private let defaults = NSUserDefaults.standardUserDefaults()
    private var authorizationCompletion: (SocialAuthenticationResult -> ())?
    
    func performAuthentication(completion: SocialAuthenticationResult -> ()) {
        
        let instance = VKSdk.initializeWithAppId(vkAppID)
        instance.registerDelegate(self)
        instance.uiDelegate = self
        
        let permissions = [VK_PER_EMAIL, VK_PER_FRIENDS, VK_PER_WALL, VK_PER_OFFLINE]
        
        VKSdk.wakeUpSession(permissions) { [weak self] state, error in
            switch state {
            case .Authorized:
                print(VKSdk.isLoggedIn())
                NSLog("%@","Already authorized, dismissing parent view controller")
                completion(.Success(socialToken: VKSdk.accessToken().accessToken))
            case .Error:
                completion(.Failure(error))
            default:
                self?.authorizationCompletion = completion
                VKSdk.authorize(permissions)
            }
        }
    }
    
    func performLogoff() {
        VKSdk.forceLogout()
    }
    
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        if let token = result.token {
            authorizationCompletion?(.Success(socialToken: token.accessToken))
        } else if let error = result.error {
            if error.vkError.errorCode == Int(VK_API_CANCELED) {
                authorizationCompletion?(.Cancelled)
            } else {
                authorizationCompletion?(.Failure(error))
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
