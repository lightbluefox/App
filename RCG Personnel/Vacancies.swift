//
//  Vacancies.swift
//  RCG Personnel
//
//  Created by iFoxxy on 19.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class Vacancies {
    var guid = ""
    var status = ""
    var topic = ""
    var shortText = ""
    var fullText = ""
    var addedDate = ""
    var postponedPublishingDate = ""
    var validTillDate = ""
    var previewImageGuid = ""
    var money = ""
    var sex = "" //сделать enum?
    var timeTable = ""
    var images = [String]()
    
    init () {
        self.guid = "";
        self.status = "";
        self.topic = "";
        self.shortText = "";
        self.fullText = "";
        self.previewImageGuid = "";
        self.addedDate = "";
        self.postponedPublishingDate = ""
        self.validTillDate = "";
        self.sex = ""
        self.money = ""
        self.timeTable = ""
        self.images = [String]()
    }
    init (guid: String, status: String, topic: String, shortText: String, fullText: String, previewImageGuid: String, addedDate: String, postponedPublishingDate: String, validTillDate: String, sex: String, money: String, timeTable: String, images: [String]) {
        self.guid = guid;
        self.status = status;
        self.topic = topic;
        self.shortText = shortText;
        self.fullText = fullText;
        self.previewImageGuid = previewImageGuid;
        self.addedDate = addedDate;
        self.postponedPublishingDate = postponedPublishingDate
        self.validTillDate = validTillDate;
        self.sex = sex
        self.money = money
        self.timeTable = timeTable
        self.images = images
    }
}