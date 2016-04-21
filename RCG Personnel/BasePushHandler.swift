//
//  PushHandler.swift
//  RCG Personnel
//
//  Created by iFoxxy on 16.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class BasePushHandler: PushHandler {
    
    var tabBar: UITabBarController
    
    func supportedFeatureName() -> String {
        return ""
    }
    
    init(tabBar: UITabBarController) {
        self.tabBar = tabBar
    }
    
    func doHandleNotification(notification: PushNotification) {
        //переопределен в каждом классе наследнике
    }
    
    func handleNotification(notification: PushNotification) -> Bool {
        let featureName = notification.payload["feature"] as! String
        let supportedFeatureName = self.supportedFeatureName()
        NSLog("%@", "Trying to handle notification. Supported feature name: " + supportedFeatureName + ". Actual feature name: " + featureName + ".")
        
        if featureName == supportedFeatureName {
            NSLog("%@", "Wotking on it.")
            self.doHandleNotification(notification)
            return false
        }
            
        else {
            NSLog("%@", "Skipped.")
            return true
        }
    }
}

