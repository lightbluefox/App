//
//  ShareManager.swift
//  RCG Personnel
//
//  Created by iFoxxy on 17.08.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class ShareManager: NSObject {
    
    let vkShareManager = VKShareManager()
    let fbShareManager = FBShareManager()
    
    func share(to socialNetworkType: SharingSocialType) {
        switch socialNetworkType {
        case .Vkontakte(let text, let image, let url, let urlText):
            vkShareManager.share(text, image: image, url: url, urlTitle: urlText)
        case .Facebook(let title, let description, let url, let imageURL):
            fbShareManager.share(title, description: description, url: url, imageURL: imageURL)
        case .Twitter:
            break
        }
    }
}

enum SharingSocialType {
    case Vkontakte(text: String, image: UIImage, url: NSURL, urlTitle: String)
    case Facebook(title: String, description: String, url: NSURL, imageURL: NSURL?)
    case Twitter
}