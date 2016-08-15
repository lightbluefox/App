//
//  NativeAuthenticationHandler.swift
//  RCG Personnel
//
//  Created by iFoxxy on 21.05.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

final class NativeAuthenticationHandler {
    
    private let user = User.sharedUser
    private let userReceiver = UserReceiver()
    
    func performAuthentication(login login: String, password: String, completion: AuthenticationResult -> ()) {
        
        let request = HTTPTask()
        let requestUrl = Constants.apiUrl + "api/v01/token"
        let params = ["login": login, "password": password]
        
        request.PUT(requestUrl, parameters: params) { response in
            if let error = response.error {
                debugPrint("error: " + error.localizedDescription)
                dispatch_async(dispatch_get_main_queue()) {
                    completion(.Failure(error))
                }
            } else {
                let data = response.responseObject as? NSData
                let jsonObject = data.flatMap {
                    try? NSJSONSerialization.JSONObjectWithData($0, options: NSJSONReadingOptions(rawValue: 0))
                }
                
                guard let json = jsonObject.flatMap({ JSON($0) }) else {
                    return completion(.Failure(nil))
                }
                
                if let error = json["error"].string {
                    print("error: " + error)
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(.Failure(nil))
                    }
                } else if let userToken = json["token"].string {
                    self.user.token = userToken
                    self.user.isAuthenticated = true
                    self.user.isTokenChecked = true
                    print("Native authentication completed, user token: \(userToken)")
                    self.userReceiver.getCurrentUser()
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(.Success)
                    }
                }
            }
        }
    }
}