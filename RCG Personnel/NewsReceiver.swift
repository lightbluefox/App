//
//  NewsReceiver.swift
//  RCG Personnel
//
//  Created by iFoxxy on 19.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation
import Alamofire

class NewsReceiver {
    var newsStack = [News]()
    var singleNews = News()
    
    func getAllNews(completionHandlerNews: (success: Bool, result: String) -> Void) {

        let requestUrl = Constants.apiUrl + "api/v01/news?count=" + Constants.newsCount
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

                for i in 0 ..< json["data"].count
                {
                    let guid = json["data"][i]["guid"] != nil ? json["data"][i]["guid"].string! : ""
                    let topic =  json["data"][i]["topic"] != nil ? json["data"][i]["topic"].string! : "";
                    let shortText = json["data"][i]["shortText"] != nil ? json["data"][i]["shortText"].string! : "";
                    let fullText = json["data"][i]["fullText"] != nil ? json["data"][i]["fullText"].string! : "";
                    let addedDate = json["data"][i]["addedDate"] != nil ? json["data"][i]["addedDate"].string!.formatedDate : "";
                    
                    var icons = [String]()
                    for u in 0 ..< json["data"][i]["icon"].count
                    {
                        icons.append(json["data"][i]["icon"][u]["url"] != nil ? json["data"][i]["icon"][u]["url"].string! : "")
                    }
                    
                    self.newsStack.append(News(guid: guid, status: "", topic: topic, shortText: shortText, fullText: fullText, icons: icons, addedDate: addedDate, postponedPublishingDate: "", validTillDate: "", images: [String]()))
                
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerNews(success: true, result: "Новости загружены")
                }
                
            }
        })
    }
    
    func getSingleNews(guid: String, completionHandlerNews: (success: Bool, result: String) -> Void){
        let requestUrl = Constants.apiUrl + "api/v01/news/" + guid
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
                self.singleNews.guid = json["guid"] != nil ? json["guid"].string! : ""
                self.singleNews.topic =  json["topic"] != nil ? json["topic"].string! : "";
                self.singleNews.shortText = json["shortText"] != nil ? json["shortText"].string! : "";
                self.singleNews.fullText = json["fullText"] != nil ? json["fullText"].string! : "";
                self.singleNews.addedDate = json["addedDate"] != nil ? json["addedDate"].string!.formatedDate : "";
                self.singleNews.validTillDate = json["validTillDate"] != nil ? json["validTillDate"].string!.formatedDate : "";
                
                for u in 0 ..< json["images"].count
                {
                    self.singleNews.images.append(json["images"][u]["url"] != nil ? json["images"][u]["url"].string! : "")
                }
                for u in 0 ..< json["icon"].count
                {
                    self.singleNews.icons.append(json["icon"][u]["url"] != nil ? json["icon"][u]["url"].string! : "")
                }
                
                //self.singleNews = News(guid: guid, status: "", topic: topic, shortText: shortText, fullText: fullText, icons: icons, addedDate: addedDate, postponedPublishingDate: "", validTillDate: validTillDate, images: images)
    
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerNews(success: true, result: "Новость загружена")
                }
    
            }
        })
    }
    /// Получает комментарии по guid новости. 
    /// Комментарии добавляются, как массив [Comments] в переменную singleNews. Можно обработать ситуацию, когда комментариев нет и отобразить соответствующую надпись.
    func getComments(guid: String, completionHandler: (success: Bool, result: String, moreCommentsAvailable: Bool) -> Void) {
        requestCommentsFromServer(guid, startFrom: singleNews.comments.count, count: singleNews.commentsStep) { success, result in
            if success {
                if self.singleNews.commentsTotal == 0 || self.singleNews.commentsTotal == self.singleNews.comments.count {
                    completionHandler(success: true, result: result, moreCommentsAvailable: false)
                }
                else {
                    completionHandler(success: true, result: result, moreCommentsAvailable: true)
                }
            }
            else {
                completionHandler(success: false, result: result, moreCommentsAvailable: true)
            }
        }
    }
    
    private func requestCommentsFromServer(guid: String, startFrom: Int, count: Int, completionHandler: (success: Bool, result: String) -> Void) {
        //api/news/b94fc5f8-3fe4-48a2-ac96-0dea2b88cae1/comments
        let relativeCommentsURL = "api/v01/news/" + guid + "/comments"
        let commentsParams = "?where=status~confirmed&offset=" + String(startFrom) + "&limit=" + String(count)
        let requestURL = Constants.apiUrl + relativeCommentsURL + commentsParams
        
        Alamofire.request(.GET, requestURL).responseJSON {response in
            switch response.result {
            case .Success:
                if let responseData = response.data {
                    var jsonError: NSError?
                    let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                    if let total = json["total"].int {
                        self.singleNews.commentsTotal = total
                        if total != 0 {
                            for u in 0 ..< json["data"].count {
                                let comment = Comments()
                                comment.userFirstName = json["data"][u]["users"]["name"].string
                                comment.userLastName = json["data"][u]["users"]["surName"].string
                                comment.userPhoto = json["data"][u]["users"]["avatar"].string
                                comment.text = json["data"][u]["text"].string
                                comment.date = json["data"][u]["addedDate"].string?.formatedDateDDMMYY
                                self.singleNews.comments.append(comment)
                            }
                            completionHandler(success: true, result: "Комментарии загружены")
                        }
                        else {
                            completionHandler(success: true, result: "Комментариев нет")
                        }
                    }
                }
            case .Failure(let error):
                completionHandler(success: false, result: error.description)
            }
        }
    }
    
}