//
//  NewsReceiver.swift
//  RCG Personnel
//
//  Created by iFoxxy on 19.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NewsReceiver {
    var newsStack = [News]()
    var singleNews = News()
    var user = User.sharedUser
    
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
        
        var headers: [String:String]?
        if user.token != nil {
            headers = ["Authorization" : "Bearer " + user.token ?? ""]
        }
        
        Alamofire.request(.GET, requestUrl, headers: headers).responseData {response in
            switch response.result {
            case .Success:
                if let responseData = response.data {
                    var jsonError: NSError?
                    let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                    
                    self.singleNews.guid = json["guid"].stringValue
                    self.singleNews.topic =  json["topic"].stringValue
                    self.singleNews.shortText = json["shortText"].stringValue
                    self.singleNews.fullText = json["fullText"].stringValue
                    self.singleNews.addedDate = json["addedDate"] != nil ? json["addedDate"].string!.formatedDate : "";
                    self.singleNews.validTillDate = json["validTillDate"] != nil ? json["validTillDate"].string!.formatedDate : "";
                    
                    for u in 0 ..< json["images"].count
                    {
                        self.singleNews.images.append(json["images"][u]["url"].stringValue)
                    }
                    for u in 0 ..< json["icon"].count
                    {
                        self.singleNews.icons.append(json["icon"][u]["url"].stringValue)
                    }
                    
                    if let canComment = json["canComment"].bool {
                        self.singleNews.canComment = canComment
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandlerNews(success: true, result: "Новость загружена")
                    }
                }
            case .Failure(let err):
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandlerNews(success: false, result: err.localizedDescription)
                }
            }
        }
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
    
    func sendCommentForNews(guid: String, comment: String, completionHandler: (success: Bool, result: String) -> Void) {
        NSLog("SendigComment. Started.")
        let headers = ["Authorization" : "Bearer " + user.token ?? ""]
        let requestUrl = Constants.apiUrl + "api/v01/news/\(guid)/comments"
        let params = ["text": comment]
        Alamofire.request(.POST, requestUrl, parameters: params, headers: headers).responseString { response in
            switch response.result {
            case .Success:
                if let responseData = response.data {
                    var jsonError: NSError?
                    let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                    if let error = json ["error"].string {
                        completionHandler(success: false, result: error)
                    }
                    else {
                        completionHandler(success: true, result: response.description)
                    }
                }
            case .Failure(let err):
                completionHandler(success: false, result: err.description)
                NSLog("SendigComment. Failed: \(err.description)")
            }
        }
        
    }
    
}
