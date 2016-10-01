//
//  PushNotification.swift
//  RCG Personnel
//
//  Created by iFoxxy on 14.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
enum PushNotificationMode {
    case Foreground //Уведолмение пришло, когда приложение было открыто
    case Background //Уведолмение пришло, когда приложение работало в фоновом режиме или было закрыто
}

class PushNotification {
    var mode : PushNotificationMode
    var payload : NSDictionary
    init(mode: PushNotificationMode, payload: NSDictionary) {
        self.mode = mode
        self.payload = payload
    }
}
