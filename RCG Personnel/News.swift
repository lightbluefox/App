//
//  News.swift
//  RCG Personnel
//
//  Created by iFoxxy on 19.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class News {
    var guid = ""
    var status = ""
    var topic = ""
    var shortText = ""
    var fullText = ""
    var addedDate = ""
    var postponedPublishingDate = ""
    var validTillDate = ""
    var icons = [String]()
    var images = [String]()
    var comments = [Comments]()
    var canComment : Bool?
    var commentsCount = 0
    var commentsStep = 10 //сколько получать комментариев за 1 запрос
    var commentsTotal = 0
    
    init () {
        self.guid = ""
        self.status = ""
        self.topic = ""
        self.shortText = ""
        self.fullText = ""
        self.addedDate = ""
        self.postponedPublishingDate = ""
        self.validTillDate = ""
        self.icons = [String]()
        self.images = [String]()
    }
    
    init (guid: String, status: String, topic: String, shortText: String, fullText: String, icons: [String], addedDate: String, postponedPublishingDate: String, validTillDate: String, images: [String]) {
        self.guid = guid;
        self.status = status;
        self.topic = topic;
        self.shortText = shortText;
        self.fullText = fullText;
        self.icons = icons;
        self.addedDate = addedDate;
        self.postponedPublishingDate = postponedPublishingDate
        self.validTillDate = validTillDate;
        self.images = images
    }
    
    init (guid: String, status: String, topic: String, shortText: String, fullText: String, icons: [String], addedDate: String, postponedPublishingDate: String, validTillDate: String, images: [String], canComment: Bool?) {
        self.guid = guid;
        self.status = status;
        self.topic = topic;
        self.shortText = shortText;
        self.fullText = fullText;
        self.icons = icons;
        self.addedDate = addedDate;
        self.postponedPublishingDate = postponedPublishingDate
        self.validTillDate = validTillDate;
        self.images = images
        self.canComment = canComment
    }
}
