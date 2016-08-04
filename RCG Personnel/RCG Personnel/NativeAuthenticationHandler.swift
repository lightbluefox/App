//
//  NativeAuthenticationHandler.swift
//  RCG Personnel
//
//  Created by iFoxxy on 21.05.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class NativeAuthenticationHandler {
    
    let user = User.sharedUser
    let userReceiver = UserReceiver()
    let hudManager = HUDManager()
    
    func performAuthentication(parentViewController: UIViewController?) {
        let loginViewController = parentViewController as! LoginViewController
        
        hudManager.parentViewController = parentViewController
        
        let request = HTTPTask();
        let requestUrl = Constants.apiUrl + "api/v01/token"
        //let params: Dictionary<String,AnyObject> = ["login":"admin", "password":"password"];
        let params: Dictionary<String,AnyObject> = ["login":loginViewController.phone.text!, "password":loginViewController.code.text!];
        
        let hud = hudManager.showHUD("Авторизуем...", details: nil, type: .Processing)
        request.PUT(requestUrl, parameters: params, completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                print("error: " + err.localizedDescription)
                dispatch_async(dispatch_get_main_queue()) {
                    self.hudManager.hideHUD(hud)
                    self.hudManager.showHUD("Ошибка", details: err.localizedDescription, type: .Failure)
                }
                
            }
            else if let resp: AnyObject = response.responseObject {
                if let data = NSString(data: resp as! NSData, encoding: NSUTF8StringEncoding) {
                
                    let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                    let jsonObject: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions(rawValue: 0))
                    let json = JSON(jsonObject)
                    
                    if let error = json["error"].string {
                        print("error: " + error)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.hudManager.hideHUD(hud)
                            self.hudManager.showHUD("Ошибка", details: error, type: .Failure)
                        }
                    }
                    else if let userToken = json["token"].string
                    {
                        self.user.token = userToken
                        self.user.isAuthenticated = true
                        self.user.isTokenChecked = true
                        print("Native authentication completed, user token: \(userToken)")
                        self.userReceiver.getCurrentUser()
                        dispatch_async(dispatch_get_main_queue()) {
                            self.hudManager.hideHUD(hud)
                            loginViewController.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                }
            }
        })
    }
}