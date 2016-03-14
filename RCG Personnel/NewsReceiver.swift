//
//  NewsReceiver.swift
//  RCG Personnel
//
//  Created by iFoxxy on 19.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class NewsReceiver {
    var newsStack = [News]()
    var singleNews = News()
    
    func getAllNews(completionHandlerNews: (success: Bool, result: String) -> Void) {

        let requestUrl = Constants.apiUrl + "api/news?count=" + Constants.newsCount
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
                let json = JSON(jsonObject)

                self.newsStack.removeAll(keepCapacity: false)

                for var i = 0; i < json["data"].count; i++
                {
                    let guid = json["data"][i]["guid"] != nil ? json["data"][i]["guid"].string! : ""
                    let topic =  json["data"][i]["topic"] != nil ? json["data"][i]["topic"].string! : "";
                    let shortText = json["data"][i]["shortText"] != nil ? json["data"][i]["shortText"].string! : "";
                    let fullText = json["data"][i]["fullText"] != nil ? json["data"][i]["fullText"].string! : "";
                    let previewImageGuid = json["data"][i]["previewImageGuid"] != nil ? json["data"][i]["previewImageGuid"].string! : "";
                    let addedDate = json["data"][i]["addedDate"] != nil ? json["data"][i]["addedDate"].string!.formatedDate : "";
                    self.newsStack.append(News(guid: guid, status: "", topic: topic, shortText: shortText, fullText: fullText, previewImageGuid: previewImageGuid, addedDate: addedDate, postponedPublishingDate: "", validTillDate: "", images: [String]()))
                
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerNews(success: true, result: "Новости загружены")
                }
                
            }
        })
    }
    
    func getSingleNews(guid: String, completionHandlerNews: (success: Bool, result: String) -> Void){
        let requestUrl = Constants.apiUrl + "api/news/" + guid
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
                    let previewImageGuid = json["previewImageGuid"] != nil ? json["previewImageGuid"].string! : "";
                    let addedDate = json["addedDate"] != nil ? json["addedDate"].string!.formatedDate : "";
                    let validTillDate = json["validTillDate"] != nil ? json["validTillDate"].string!.formatedDate : "";
                    let images = json["images"] != nil ? json["images"].arrayObject as! [String] : [String]();
                    
                    self.singleNews = News(guid: guid, status: "", topic: topic, shortText: shortText, fullText: fullText, previewImageGuid: previewImageGuid, addedDate: addedDate, postponedPublishingDate: "", validTillDate: validTillDate, images: images)
    
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerNews(success: true, result: "Новости загружены")
                }
    
            }
        })
    }
}