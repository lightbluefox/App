//
//  PushHandler.swift
//  RCG Personnel
//
//  Created by iFoxxy on 16.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

protocol PushHandler {
    
    func handleNotification(_: PushNotification) -> Bool
}