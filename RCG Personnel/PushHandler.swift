//
//  PushHandler.swift
//  RCG Personnel
//
//  Created by iFoxxy on 16.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

protocol PushHandler {
    
    func handleNotification(_: PushNotification) -> Bool
}
