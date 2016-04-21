//
//  PushManager.swift
//  RCG Personnel
//
//  Created by iFoxxy on 14.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class PushManager: NavigationManager {
    
    var handlers = [PushHandler]()
    
    init(handlers: [PushHandler]) {
        self.handlers = handlers
    }
    
    func handlePush(notification: PushNotification, sender: AnyObject) {
        let handled = false
        for handler in handlers {
            if handled == handler.handleNotification(notification) {
                break
            }
        }
    }
}