//
//  User.swift
//  RCG Personnel
//
//  Created by iFoxxy on 23.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import Alamofire

enum Gender {
    case Male
    case Female
}

class User {
    
    let noPhotoImage = UIImage(named: "nophoto_user") as UIImage?
    var guid : String?
    var photoUrl : String?
    var firstName: String?
    var middleName: String?
    var lastName: String?
    var phone: String?
    var email: String?
    
    //FullData
    var gender: Gender?
    var birthDate: String?
    var height: Int?
    var size: Int? 
    var hasMedicalBook: Bool?
    var theMedicalBookNumber: String?
    var medicalBookNumber: String? {
        get {
            if let notEmpty = hasMedicalBook {
                if !notEmpty {
                    return "Нет"
                }
            }
            return self.theMedicalBookNumber ?? ""
        }
        set(newValue) {
            self.theMedicalBookNumber = newValue
        }
    }
    var metroStation: String?
    var passportData: String?
    
    var isTokenChecked = false
    var isAuthenticated = false
    var token: String! {
        get {
           return NSUserDefaults.standardUserDefaults().stringForKey(NSUserDefaultsKeys.tokenKey)
        }
        set(newToken) {
            NSUserDefaults.standardUserDefaults().setObject(newToken, forKey: NSUserDefaultsKeys.tokenKey)
            
        }
    }
    
    var fullName: String? {
        get {
            if lastName == nil && firstName == nil && middleName == nil {
                return nil
            }
            else {
                var l = ""
                var f = ""
                var m = ""
                if lastName != nil {
                    l = "\(lastName!) "
                }
                if middleName != nil {
                    m = "\(middleName!)"
                }
                if firstName != nil {
                    f = "\(firstName!) "
                }
                return l+f+m
            }
        }
    }
    
    var age: String? {
        get {
            if let bd = birthDate {
                if let doubleBD = Double(bd) {
                    let calendar = NSCalendar.currentCalendar()
                    let birthdate = calendar.startOfDayForDate(NSDate(timeIntervalSince1970: doubleBD/1000))
                    let currentdate = NSDate()
                    let flags = NSCalendarUnit.Year
                    let components = calendar.components(flags, fromDate: birthdate, toDate: currentdate, options: [])
                    return String(components.year)
                }
            }
            return "0"
        }
    }
    
    var vkToken: String!
    var fbToken: String!
    var twToken: String!
    
    func tokenForSocialNetwork(socialNetwork: SocialNetwork) -> String? {
        switch socialNetwork {
        case .VKontakte:
            return vkToken
        case .Facebook:
            return fbToken
        case .Twitter:
            return twToken
        }
    }
    
    static let sharedUser = User()
    
    init() {
        
    }
    
    init(photo: String, firstName: String, middleName: String, lastName: String, phone: String, email: String, birthDate: String, height: Int, size: Int, hasMedicalBook: Bool, medicalBookNumber: String, metroStation: String, passportData: String, gender: Gender) {
        self.photoUrl = photo
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.phone = phone
        self.email = email
        self.birthDate = birthDate
        self.height = height
        self.size = size
        self.hasMedicalBook = hasMedicalBook
        self.medicalBookNumber = medicalBookNumber
        self.metroStation = metroStation
        self.passportData = passportData
        self.gender = gender
    }
}
