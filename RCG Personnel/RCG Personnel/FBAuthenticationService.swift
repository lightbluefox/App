//
//  FBAuthenticationHanler.swift
//  RCG Personnel
//
//  Created by iFoxxy on 17.05.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

final class FBAuthenticationService: BaseAuthenticationHandler {
 
    private let facebookReadPermissions = ["public_profile", "email", "user_friends"]
    
    func performLogoff() {
        FBSDKLoginManager().logOut()
    }
    
    func performAuthentication(completion: SocialAuthenticationResult -> ()) {
        loginToFacebookWithSuccess({ token in
            completion(.Success(socialToken: token))
        }, andFailure: { error in
            completion(.Failure(error))
        })
    }
    
    private func loginToFacebookWithSuccess(successBlock: (token: String) -> (), andFailure failureBlock: (NSError?) -> ()) {
        
        if let currentToken = FBSDKAccessToken.currentAccessToken() {
            successBlock(token: currentToken.tokenString)
            //For debugging, when we want to ensure that facebook login always happens
            //FBSDKLoginManager().logOut()
            //Otherwise do:
            return
        }
        
        FBSDKLoginManager().logInWithReadPermissions(self.facebookReadPermissions, fromViewController: nil ,handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                //According to Facebook:
                //Errors will rarely occur in the typical login flow because the login dialog
                //presented by Facebook via single sign on will guide the users to resolve any errors.
                
                // Process error
                FBSDKLoginManager().logOut()
                failureBlock(error)
            } else if result.isCancelled {
                // Handle cancellations
                FBSDKLoginManager().logOut()
                failureBlock(nil)
            } else {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                //var allPermsGranted = true
                
                //result.grantedPermissions returns an array of _NSCFString pointers
                /*let grantedPermissions = result.grantedPermissions.map( {"\($0)"} )
                for permission in self.facebookReadPermissions {
                    if !grantedPermissions.contains(permission) {
                        allPermsGranted = false
                        break
                    }
                }*/
                //if allPermsGranted {
                    // Do work
                    
                    //Send fbToken and fbUserID to your web API for processing, or just hang on to that locally if needed
                    //self.post("myserver/myendpoint", parameters: ["token": fbToken, "userID": fbUserId]) {(error: NSError?) ->() in
                    //	if error != nil {
                    //		failureBlock(error)
                    //	} else {
                    //		successBlock(maybeSomeInfoHere?)
                    //	}
                    //}
                    
                    successBlock(token: result.token.tokenString)
                //} else {
                    //The user did not grant all permissions requested
                    //Discover which permissions are granted
                    //and if you can live without the declined ones
                    
                  //  failureBlock(nil)
                //}
            }
        })
    }
}

