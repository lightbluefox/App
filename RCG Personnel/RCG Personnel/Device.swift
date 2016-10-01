//
//  Device.swift
//  RCG Personnel
//
//  Created by iFoxxy on 07.09.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class Device {
    
    var token : String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(NSUserDefaultsKeys.deviceTokenKey)
        }
        set(newToken) {
            NSUserDefaults.standardUserDefaults().setObject(newToken, forKey: NSUserDefaultsKeys.deviceTokenKey)
            
        }
    }
    
    var tokenSent : Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(NSUserDefaultsKeys.deviceTokenSentKey)
        }
        set(newToken) {
            NSUserDefaults.standardUserDefaults().setObject(newToken, forKey: NSUserDefaultsKeys.deviceTokenSentKey)
            
        }
    }
    
    static let sharedDevice = Device()
    
    init() {
        
    }
    
}
