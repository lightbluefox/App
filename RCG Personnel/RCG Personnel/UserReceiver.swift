//
//  UserReceiver.swift
//  RCG Personnel
//
//  Created by iFoxxy on 16.07.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation
import Alamofire

class UserReceiver {
    var photoDidChange = false
    let user = User.sharedUser
    
    ///Gets current user properties by token from authorization header
    
    func getCurrentUser() {
        /*JSON format:
         {
         "guid": "00000011-f314-1f31-0fee-000011112222"
         "login": "admin"
         "groups": [1]
         0:  "admin"
         -
         "usersdata": {
         "name": "Roman"
         "surName": "Samokhin"
         "fatherName": null
         "ifMale": null
         "email": "email@mail.ru"
         "avatar": "http://jsymphony.com/img/avatar.jpg"
         "birthDate": null
         "height": null
         "clothesSize": null
         "hasMedicalCard": null
         "medicalCardNumber": null
         "subWayStation": null
         "passportData": null
         "vkid": null
         "fbid": null
         "twid": null
         "registeredDate": null
         }-
         }*/
        NSLog("GetUserByToken. Started.")
        let headers = ["Authorization" : "Bearer " + user.token ?? ""]
        Alamofire.request(.GET, Constants.apiUrl + "api/v01/users/current", headers: headers)
            .responseData {response in
                switch response.result {
                case .Success:
                    if let responseData = response.data {
                        var jsonError: NSError?
                        let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                        self.user.guid = json["guid"].stringValue
                        self.user.phone = json["login"].stringValue
                        self.user.photoUrl = json["usersdata"]["avatar"].stringValue
                        self.user.firstName = json["usersdata"]["name"].stringValue
                        self.user.middleName = json["usersdata"]["fatherName"].stringValue
                        self.user.lastName = json["usersdata"]["surName"].stringValue
                        self.user.email = json["usersdata"]["email"].stringValue
                        
                        //FullData
                        
                        switch json["usersdata"]["ifMale"].boolValue {
                        case true:
                            self.user.gender = .Male
                        case false:
                            self.user.gender = .Female
                        }
                        self.user.birthDate = json["usersdata"]["birthDate"].stringValue
                        self.user.height = json["usersdata"]["height"].intValue
                        self.user.size = json["usersdata"]["clothesSize"].intValue
                        self.user.hasMedicalBook = json["usersdata"]["hasMedicalCard"].boolValue
                        self.user.medicalBookNumber = json["usersdata"]["medicalCardNumber"].stringValue
                        self.user.metroStation = json["usersdata"]["subWayStation"].stringValue
                        self.user.passportData = json["usersdata"]["passportData"].stringValue
                        self.user.vkToken = json["vkid"].stringValue
                        self.user.fbToken = json["fbid"].stringValue
                        self.user.twToken = json["twid"].stringValue
                        
                        NSLog("GetUserByToken. Done with success.")
                        NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationCenterKeys.notifyThatUserHaveBeenUpdated, object: self)
                    }
                case .Failure:
                    NSLog("GetUserByToken. Done with failure. See the description below.")
                    NSLog((response.result.error?.description)!)
                }
        }
    }
    
    ///Updates current user properties on server
    func updateCurrentUserWithValues(photoUrl: String, firstName: String, middleName: String, lastName: String, email: String, birthDate: String, medicalBookNumber: String, metroStation: String, passportData: String, height: Int, size: Int, hasMedicalBook: Bool, gender: Gender, vkToken: String?, fbToken: String?, twToken: String?, completionHandler: (success: Bool, result: String) -> Void) {
        
        NSLog("UpdatingUserByToken. Started")
        let headers = ["Authorization" : "Bearer " + user.token ?? ""]
        var params : Dictionary<String,AnyObject> = ["":""]
        func setParams() {
            if firstName != "" {
                params.updateValue(firstName, forKey: "name")
            }
            if middleName != "" {
                params.updateValue(middleName, forKey: "fatherName")
            }
            if lastName != "" {
                params.updateValue(lastName, forKey: "surName")
            }
            if email != "" {
                params.updateValue(email, forKey: "email")
            }
            if birthDate != "" {
                params.updateValue(birthDate.timeIntervalSince1970FromDdMmYyyy ?? "", forKey: "birthDate")
            }
            if medicalBookNumber != "" {
                params.updateValue(medicalBookNumber, forKey: "medicalCardNumber")
            }
            if metroStation != "" {
                params.updateValue(metroStation, forKey: "subWayStation")
            }
            if passportData != "" {
                params.updateValue(passportData, forKey: "passportData")
            }
            if height != 0 {
                params.updateValue(height, forKey: "height")
            }
            if size != 0 {
                params.updateValue(size, forKey: "clothesSize")
            }
            params.updateValue(user.hasMedicalBook ?? false, forKey: "hasMedicalCard")
            params.updateValue(gender == .Male ? true : false, forKey: "ifMale")
            params.updateValue(photoUrl, forKey: "avatar")
            /*
             params.updateValue(vkToken, forKey: "vkid")
             params.updateValue(fbToken, forKey: "fbid")
             params.updateValue(twToken, forKey: "twid")
             Придумать, как обновлять токен вк/фб/тв после подключения соцсети
             */
        }
        setParams()
        
        
        
        Alamofire.request(.PUT, Constants.apiUrl + "api/v01/users/current", headers: headers, parameters: params).responseJSON {response in
            switch response.result {
            case .Success:
                if let responseData = response.data {
                    var jsonError: NSError?
                    let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                    self.user.photoUrl = json["usersdata"]["avatar"].stringValue
                    self.user.firstName = json["usersdata"]["name"].stringValue
                    self.user.middleName = json["usersdata"]["fatherName"].stringValue
                    self.user.lastName = json["usersdata"]["surName"].stringValue
                    self.user.email = json["usersdata"]["email"].stringValue
                    
                    //FullData
                    
                    switch json["usersdata"]["ifMale"].boolValue {
                    case true:
                        self.user.gender = .Male
                    case false:
                        self.user.gender = .Female
                    }
                    self.user.birthDate = json["usersdata"]["birthDate"].stringValue
                    self.user.height = json["usersdata"]["height"].intValue
                    self.user.size = json["usersdata"]["clothesSize"].intValue
                    self.user.hasMedicalBook = json["usersdata"]["hasMedicalCard"].boolValue
                    self.user.medicalBookNumber = json["usersdata"]["medicalCardNumber"].stringValue
                    self.user.metroStation = json["usersdata"]["subWayStation"].stringValue
                    self.user.passportData = json["usersdata"]["passportData"].stringValue
                    
                    NSLog("UpdatingUserByToken. Done with success.")
                    NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationCenterKeys.notifyThatUserHaveBeenUpdated, object: self)
                    
                    completionHandler(success: true, result: "Success")
                }
            case .Failure:
                NSLog("UpdatingUserByToken. Done with failure. See the description below.")
                NSLog((response.result.error?.description)!)
                completionHandler(success: false, result: (response.result.error?.description)!)
            }
        }
    }
    
    func uploadPhoto(photo: UIImage, completionHandler: (isSuccess: Bool, error: String?) -> Void) {
        NSLog("UploadingPhotoForUser. Started")
        
        let headers = ["Authorization" : "Bearer " + user.token ?? ""]
        if let nsdataFromPhoto = UIImageJPEGRepresentation(photo, 0.5) {
            Alamofire.upload(.POST, Constants.apiUrl + "api/v01/images", headers: headers, multipartFormData: {
                multipartFormData in
                multipartFormData.appendBodyPart(data: nsdataFromPhoto, name: "image", fileName: "image.png", mimeType: "image/png")
            }, encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                        upload.responseString { response in
                            switch response.result {
                            case .Success:
                                if response.result.value == "Not Found"
                                {
                                    print(response.result.value!)
                                }
                                else if let responseData = response.data {
                                    var jsonError: NSError?
                                    let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                                    self.user.photoUrl = json["url"].stringValue
                                    NSLog("UploadingPhotoForUser. Done.")
                                    completionHandler(isSuccess: true, error: nil)
                                }
                            case .Failure(let error):
                                NSLog("UploadingPhotoForUser. Failed with error: \(error.description)")
                                completionHandler(isSuccess: false, error: error.description)
                            }
                    }
                case .Failure(let encodingError):
                    NSLog("UploadingPhotoForUser. Failed on encoding: \(encodingError)")
                    completionHandler(isSuccess: false, error: "Не удалось преобразовать изображение.")
                }
            })
        }
    }
    
    
}