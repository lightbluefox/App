//
//  User.swift
//  RCG Personnel
//
//  Created by iFoxxy on 23.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation
import Alamofire

enum Gender {
    case Male
    case Female
    
    var localizedTitle: String {
        switch self {
        case .Male:
            return "Мужской"
        case .Female:
            return "Женский"
        }
    }
}

// TODO: сделать структурой
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
    var birthDate: String?  // TODO: это должна быть дата, а не строка
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
    
    @available(*, deprecated, message="Брать из AuthenticationService")
    var isTokenChecked = false
    
    @available(*, deprecated, message="Брать из AuthenticationService")
    var isAuthenticated = false
    
    @available(*, deprecated, message="Брать из AuthenticationService")
    var token: String!
    
    var fullName: String? {
        get {
            let l = lastName ?? ""
            let f = firstName ?? ""
            let m = middleName ?? ""
            return l + " " + f + " " + m
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
    
    var vkToken: String?
    var fbToken: String?
    var twToken: String?
    
    // TODO: выпилить. Текущего юзера получать через AuthenticationService.currentUser(_:)
    @available(*, deprecated, message="Текущего юзера получать через AuthenticationService.currentUser(_:)")
    static let sharedUser = User()
    
    init() {}
    
    init(photo: String?,
         firstName: String?,
         middleName: String?,
         lastName: String?,
         phone: String?,
         email: String?,
         birthDate: String?,
         height: Int?,
         size: Int?,
         hasMedicalBook: Bool?,
         medicalBookNumber: String?,
         metroStation: String?,
         passportData: String?,
         gender: Gender?)
    {
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
    
    var requiredFieldsFilled: Bool {
        // Это минимальная проверка, она пропустит пустые строки
        return phone?.isEmpty == false &&
               firstName?.isEmpty == false &&
               lastName?.isEmpty == false &&
               email?.isEmpty == false &&
               gender != nil &&
               birthDate?.isEmpty != nil &&
               height != nil &&
               size != nil &&
               metroStation?.isEmpty == false &&
               passportData?.isEmpty == false
    }
}
