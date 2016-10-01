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
    
    var tokenSent = false
    
    static let sharedDevice = Device()
    
    init() {
        
    }
    
}
