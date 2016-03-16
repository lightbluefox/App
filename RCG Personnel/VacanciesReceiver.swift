//
//  VacanciesReceiver.swift
//  RCG Personnel
//
//  Created by iFoxxy on 19.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class VacanciesReceiver {
    var vacsStack = [Vacancies]()
    var singleVacancy = Vacancies()
    
    func getAllVacs(completionHandlerNews: (success: Bool, result: String) -> Void) {
        vacsStack.removeAll(keepCapacity: false);
        
        let currentDate = String(NSDate().gmc0.timeIntervalSince1970*1000)
        //let requestUrl = Constants.apiUrl + "api/vacancies?count=1000&where=validTillDate>=" + currentDate
        let requestUrl = Constants.apiUrl + "api/vacancies?count=" + Constants.vacancyCount
        
        let request = HTTPTask()
        request.GET(requestUrl, parameters: nil, completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerNews(success: false, result: err.localizedDescription)
                }
                return
            }
            else if let data = response.responseObject as? NSData {
                let requestedData = NSString(data: data, encoding: NSUTF8StringEncoding)
                let requestedDataUnwrapped = requestedData!;
                let jsonString = requestedDataUnwrapped;
                let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                let jsonObject: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions(rawValue: 0))
                
                let json = JSON(jsonObject);
                for var i = 0; i < json["data"].count; i++
                {
                    let guid = json["data"][i]["guid"] != nil ? json["data"][i]["guid"].string! : ""
                    let topic =  json["data"][i]["topic"] != nil ? json["data"][i]["topic"].string! : "";
                    let shortText = json["data"][i]["shortText"] != nil ? json["data"][i]["shortText"].string! : "";
                    let fullText = json["data"][i]["fullText"] != nil ? json["data"][i]["fullText"].string! : "";
                    let addedDate = json["data"][i]["addedDate"] != nil ? json["data"][i]["addedDate"].string! : "";
                    let sex =  json["data"][i]["sex"] != nil ? json["data"][i]["sex"].string! : "";
                    let money =  json["data"][i]["money"] != nil ? json["data"][i]["money"].string! : "";
                    let validTillDate = json["data"][i]["validTillDate"] != nil ? json["data"][i]["validTillDate"].string! : "";
                    
                    var icons = [String]()
                    for var u = 0; u < json["data"][i]["icon"].count; u++
                    {
                        icons.append(json["data"][i]["icon"][u]["url"] != nil ? json["data"][i]["icon"][u]["url"].string! : "")
                    }
                    
                    self.vacsStack.append(Vacancies(guid: guid, status: "", topic: topic, shortText: shortText, fullText: fullText, icons: icons, addedDate: addedDate, postponedPublishingDate: "", validTillDate: validTillDate, sex: sex, money: money, timeTable: "", images: [String]()))
                    
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerNews(success: true, result: "Вакансии загружены")
                }
                
            }
        })
    }
    
    func getSingleVac(guid: String, completionHandlerNews: (success: Bool, result: String) -> Void){
        let requestUrl = Constants.apiUrl + "api/vacancies/" + guid
        let request = HTTPTask()
        request.GET(requestUrl, parameters: nil, completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerNews(success: false, result: err.localizedDescription)
                }
                return
            }
            else if let data = response.responseObject as? NSData {
                let requestedData = NSString(data: data, encoding: NSUTF8StringEncoding)
                let requestedDataUnwrapped = requestedData!;
                let jsonString = requestedDataUnwrapped;
                let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                let jsonObject: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions(rawValue: 0))
                
                let json = JSON(jsonObject);
                let guid = json["guid"] != nil ? json["guid"].string! : ""
                let topic =  json["topic"] != nil ? json["topic"].string! : "";
                let shortText = json["shortText"] != nil ? json["shortText"].string! : "";
                let fullText = json["fullText"] != nil ? json["fullText"].string! : "";
                let addedDate = json["addedDate"] != nil ? json["addedDate"].string! : "";
                let validTillDate = json["validTillDate"] != nil ? json["validTillDate"].string! : "";
                let postponedPublishingDate = json["postponedPublishingDate"] != nil ? json["postponedPublishingDate"].string! : "";
                let sex = json["sex"] != nil ? json["sex"].string! : "";
                let money = json["money"] != nil ? json["money"].string! : "";
                let timeTable = json["timeTable"] != nil ? json["timeTable"].string! : "";
                
                var images = [String]()
                for var u = 0; u < json["images"].count; u++
                {
                    images.append(json["images"][u]["url"] != nil ? json["images"][u]["url"].string! : "")
                }
                var icons = [String]()
                for var u = 0; u < json["icon"].count; u++
                {
                    icons.append(json["icon"][u]["url"] != nil ? json["icon"][u]["url"].string! : "")
                }
                
                self.singleVacancy = Vacancies(guid: guid, status: "", topic: topic, shortText: shortText, fullText: fullText, icons: icons, addedDate: addedDate, postponedPublishingDate: postponedPublishingDate, validTillDate: validTillDate, sex: sex, money: money, timeTable: timeTable, images: images)
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerNews(success: true, result: "Вакансия загружена")
                }
            }
        })
    }
}