//
//  VacanciesReceiver.swift
//  RCG Personnel
//
//  Created by iFoxxy on 19.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation
import Alamofire
import SwiftHTTP

class VacanciesReceiver {
    var vacsStack = [Vacancies]()
    var singleVacancy = Vacancies()
    let user = User.sharedUser
    
    func getAllVacs(completionHandlerVacs: (success: Bool, result: String) -> Void) {
        vacsStack.removeAll(keepCapacity: false);
        
        let currentDate = String(NSDate().gmc0.timeIntervalSince1970*1000)
        let requestUrl = Constants.apiUrl + "api/v01/vacancies?limit=" + Constants.vacancyCount + "&where=validTillDate>=" + currentDate
        let request = HTTPTask()
        request.GET(requestUrl, parameters: nil, completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerVacs(success: false, result: err.localizedDescription)
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
                for i in 0 ..< json["data"].count
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
                    for u in 0 ..< json["data"][i]["icon"].count
                    {
                        icons.append(json["data"][i]["icon"][u]["url"] != nil ? json["data"][i]["icon"][u]["url"].string! : "")
                    }
                    
                    self.vacsStack.append(Vacancies(guid: guid, status: "", topic: topic, shortText: shortText, fullText: fullText, icons: icons, addedDate: addedDate, postponedPublishingDate: "", validTillDate: validTillDate, sex: sex, money: money, timeTable: "", images: [String](), userReplied: nil))
                    
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerVacs(success: true, result: "Вакансии загружены")
                }
                
            }
        })
    }
    
    func getSingleVac(guid: String, completionHandlerVacs: (success: Bool, result: String) -> Void){
        
        var headers : [String: String]? = nil
        if user.token != nil {
            headers = ["Authorization" : "Bearer " + user.token ?? ""]
        }
        
        let requestUrl = Constants.apiUrl + "api/v01/vacancies/" + guid
        Alamofire.request(.GET, requestUrl, parameters: nil, headers: headers).responseData {response in
            switch response.result {
            case .Success:
                if let responseData = response.data {
                    var jsonError: NSError?
                    let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                    
                    let guid = json["guid"].stringValue
                    let topic =  json["topic"].stringValue
                    let shortText = json["shortText"].stringValue
                    let fullText = json["fullText"].stringValue
                    let addedDate = json["addedDate"].stringValue
                    let validTillDate = json["validTillDate"].stringValue
                    let postponedPublishingDate = json["postponedPublishingDate"].stringValue
                    let sex = json["sex"].stringValue
                    let money = json["money"].stringValue
                    let timeTable = json["timeTable"].stringValue
                    
                    var images = [String]()
                    for u in 0 ..< json["images"].count
                    {
                        images.append(json["images"][u]["url"].stringValue)
                    }
                    var icons = [String]()
                    for u in 0 ..< json["icon"].count
                    {
                        icons.append(json["icon"][u]["url"].stringValue)
                    }
                    var replied : Bool?
                    if let userReplied = json["userReplied"].bool {
                        replied = userReplied
                    }
                    
                    self.singleVacancy = Vacancies(guid: guid, status: "", topic: topic, shortText: shortText, fullText: fullText, icons: icons, addedDate: addedDate, postponedPublishingDate: postponedPublishingDate, validTillDate: validTillDate, sex: sex, money: money, timeTable: timeTable, images: images, userReplied: replied)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandlerVacs(success: true, result: "Вакансия загружена")
                    }
                }
            case .Failure(let err):
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerVacs(success: false, result: err.localizedDescription)
                }
            }
        }
    }
}
