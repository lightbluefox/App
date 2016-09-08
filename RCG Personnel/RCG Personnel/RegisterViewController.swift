//
//  RegisterViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 30.05.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation
import PhoneNumberKit

enum RegistrationResult {
    case NativeSuccess(login: String, password: String)
    case SocialSuccess(network: SocialNetwork, token: String, tokenSecret: String?)
}

final class RegisterViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ValidatePhoneViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var socialNetwork: SocialNetwork?
    var socialToken: String?
    var tokenSecret: String?
    
    var onFinish: ((RegistrationResult) -> ())?
    
    @IBAction func closeButtonTouched(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
     "name": null,
     "surName": null,
     "fatherName": null,
     "ifMale": null,
     "email": null,
     "avatar": null,
     "birthDate": null,
     "height": null,
     "clothesSize": null,
     "hasMedicalCard": null,
     "medicalCardNumber": null,
     "subWayStation": null,
     "passportData": null,
     "vkid": null,
     "fbid": null,
     "twid": null
     */
    @IBOutlet weak var scrollView: UIScrollView!
    var clearPhone = ""
    
    @IBOutlet weak var phoneNumber: RCGPhoneTextField!
    @IBOutlet weak var firstName: RCGTextFieldClass!
    @IBOutlet weak var middleName: RCGTextFieldClass!
    @IBOutlet weak var lastName: RCGTextFieldClass!
    @IBOutlet weak var sex: RCGTextFieldClass!
    @IBOutlet weak var email: RCGTextFieldClass!
    @IBOutlet weak var birthDate: RCGTextFieldClass!
    @IBOutlet weak var height: RCGTextFieldClass!
    @IBOutlet weak var clothesSize: RCGTextFieldClass!
    @IBOutlet weak var hasMedicalCard: RCGUISwitch!
    @IBOutlet weak var scrollViewBottomMargin: NSLayoutConstraint!
    var scrollViewBottomMarginConstant: CGFloat = 0
    @IBAction func hasMedicalCardSwitched(sender: UISwitch) {
        if sender.on {
            medicalCardNumber.hidden = false
            fieldsAreValid.updateValue(medicalCardNumber.isValid, forKey: medicalCardNumber)
            subwayStationTopMarginFromMedicalCardUISwitch.constant = 60 //высота поля 30 + 2 отступа по 15
        }
        else {
            medicalCardNumber.hidden = true
            fieldsAreValid.removeValueForKey(medicalCardNumber)
            subwayStationTopMarginFromMedicalCardUISwitch.constant = 15
            
        }
    }
    
    @IBOutlet weak var medicalCardNumberBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var medicalCardNumberHeight: NSLayoutConstraint!
    @IBOutlet weak var medicalCardNumber: RCGTextFieldClass!
    @IBOutlet weak var subwayStationTopMarginFromMedicalCardUISwitch: NSLayoutConstraint!
    @IBOutlet weak var SubwayStation: RCGTextFieldClass!
    @IBOutlet weak var passport: RCGTextFieldClass!
    @IBAction func registerButtonTouched(sender: AnyObject) {
        if fieldsAreValid.values.contains(false) {
            hudManager.showHUD("Ошибка", details: "Все поля обязательны для заполнения", type: .Failure)
        }
        else {
            let bdate = birthDate.text?.timeIntervalSince1970FromDdMmYyyy
            let heightFinal = height.text ?? "0"
            let sizeFinal = clothesSize.text ?? "0"
            if let unwrappedPhone = self.phoneNumber.text {
                clearPhone = removeInvalidCharacters(unwrappedPhone, charactersString: "0123456789")
            }
            var gender = Gender.Male
            if sex.text == "Женский" {
                gender = Gender.Female
            }
            else {
                gender = Gender.Male
            }
            
            let user = User(
                photo: "",
                firstName: firstName.text ?? "",
                middleName: middleName.text ?? "",
                lastName: lastName.text ?? "",
                phone: clearPhone,
                email: email.text ?? "",
                birthDate: bdate ?? "",
                height: Int(heightFinal) ?? 0,
                size: Int(sizeFinal) ?? 0,
                hasMedicalBook: hasMedicalCard.on,
                medicalBookNumber: medicalCardNumber.text ?? "",
                metroStation: SubwayStation.text ?? "",
                passportData: passport.text ?? "",
                gender: gender
            )
            
            authenticationManager.registerNewUser(
                self,
                user: user,
                socialNetwork: socialNetwork,
                socialToken: socialToken,
                tokenSecret: tokenSecret
            )
            
            //authenticationManager.registerNewUser(self, user: User(photo: "https://lh5.googleusercontent.com/-MlnvEdpKY2w/AAAAAAAAAAI/AAAAAAAAAFw/x6wHNLJmtQ0/s0-c-k-no-ns/photo.jpg", firstName: "Иван", middleName: "Петрович", lastName: "Путинов", phone: self.phoneNumber.text ?? "", email: "mail@mail.ru", birthDate: "22.07.1912", height: 180, size: 42, hasMedicalBook: true, medicalBookNumber: "1231231", metroStation: "Севастопольская", passportData: "1231 312312", gender: .Male))
        }
    }
    
    @IBAction func editingDidEnd(sender: RCGTextFieldClass) {
        sender.validate()
        fieldsAreValid.updateValue(sender.isValid, forKey: sender)

    }
    
    var fieldsAreValid = [UITextField : Bool]()
    var validationCode: String?
    var hudManager = HUDManager()
    let imagePicker = UIImagePickerController()
    var genderPickerData = [String]()
    let validatePhoneViewController = ValidatePhoneViewController()
    var authenticationManager = AuthenticationManager()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.hudManager.parentViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fieldsAreValid = [
            phoneNumber : phoneNumber.isValid,
            firstName : firstName.isValid,
            middleName : middleName.isValid,
            lastName :lastName.isValid,
            sex : sex.isValid,
            email : email.isValid,
            birthDate : birthDate.isValid,
            height : height.isValid,
            clothesSize : clothesSize.isValid,
            SubwayStation : SubwayStation.isValid,
            passport : passport.isValid
        ]
        
        setupView()
        addGenderPickerViewOnTap(forTextField: sex)
        addDatePickerViewOnTap(forTextField: birthDate)
    }

    private func setupView() {
        prepareScrollView()
        firstName.autocapitalizationType = .Words
        lastName.autocapitalizationType = .Words
        middleName.autocapitalizationType = .Words
        SubwayStation.autocapitalizationType = .Sentences
        phoneNumber.keyboardType = .PhonePad
        email.keyboardType = .EmailAddress
        height.keyboardType = .NumberPad
        clothesSize.keyboardType = .NumberPad
        //phoneNumber.becomeFirstResponder()
        
        //Чтобы в методе textView сделать форматирование вводимого номера налету
        phoneNumber.delegate = self
        //Чтобы в методе textView запретить вводить какие-либо значения кроме чисел
        height.delegate = self
        clothesSize.delegate = self
    }
    
    private func prepareScrollView() {
        //MARK: Скрывать, клавиатуру при тапе по скрол вью
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)));
        tap.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tap)
        setScrollViewSqueezeOnKeyboardAppearаnce()
    }
    
    func hideKeyboard(sender: AnyObject) {
        scrollView.endEditing(true)
    }
    
    private func setScrollViewSqueezeOnKeyboardAppearаnce() {
        self.scrollViewBottomMarginConstant = self.scrollViewBottomMargin.constant;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.CGRectValue()
                self.scrollViewBottomMargin.constant = self.scrollViewBottomMarginConstant + frame.size.height
                
                switch (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber) {
                case let (.Some(duration), .Some(curve)):
                    
                    let options = UIViewAnimationOptions(rawValue: curve.unsignedLongValue)
                    
                    UIView.animateWithDuration(
                        NSTimeInterval(duration.doubleValue),
                        delay: 0,
                        options: options,
                        animations: {
                            UIApplication.sharedApplication().keyWindow?.layoutIfNeeded()
                            return
                        }, completion: { finished in
                    })
                default:
                    
                    break
                }
            }
        }
    }
    
    func keyboardWillHideNotification(notification: NSNotification){
        self.scrollViewBottomMargin.constant = self.scrollViewBottomMarginConstant
        if let userInfo = notification.userInfo {
            
            switch (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.Some(duration), .Some(curve)):
                
                let options = UIViewAnimationOptions(rawValue: curve.unsignedLongValue)
                
                UIView.animateWithDuration(
                    NSTimeInterval(duration.doubleValue),
                    delay: 0,
                    options: options,
                    animations: {
                        UIApplication.sharedApplication().keyWindow?.layoutIfNeeded()
                        return
                    }, completion: { finished in
                })
            default:
                break
            }
        }
    }
    
    //MARK: ValidatePhoneDelegate
    func didFinishValidating(sender: ValidatePhoneViewController) {
        
        if let socialNetwork = socialNetwork {
            onFinish?(.SocialSuccess(network: socialNetwork, token: socialToken ?? "", tokenSecret: tokenSecret))
        } else {
            onFinish?(.NativeSuccess(login: phoneNumber.unmaskText() ?? "", password: sender.code.text ?? ""))
        }
        
        // TODO: это тоже должен делать родительский контроллер в onFinish
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    //MARK: UIPickerViewDelegate
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderPickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderPickerData[row]
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        self.sex.text = genderPickerData[row]
    }
    
    ///Создает PickerView с выбором пола, который открывается при тапе на TextField
    private func addGenderPickerViewOnTap(forTextField sender: UITextField) {
        let pickerView = UIPickerView.init(frame: CGRectMake(0, 50, 100, 150))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        self.genderPickerData = ["Мужской", "Женский"]
        sender.inputView = pickerView
        
        //Чтобы в функции textField() запретить пользователям вставлять или изменять
        sender.delegate = self
    }
    
    private func addDatePickerViewOnTap(forTextField sender: UITextField) {
        let datePickerView = UIDatePicker.init(frame: CGRectMake(0,50, 100,150))
        datePickerView.datePickerMode = .Date
        datePickerView.addTarget(self, action: #selector(setValueFromDatePickerToBirhDateTextField(_:)), forControlEvents: .ValueChanged)
        sender.inputView = datePickerView
        
        //Чтобы в функции textField() запретить пользователям вставлять или изменять
        sender.delegate = self
    }
    
    func setValueFromDatePickerToBirhDateTextField(datepicker: UIDatePicker) {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let selectedDate = dateFormatter.stringFromDate(datepicker.date)
        self.birthDate.text = selectedDate
        
    }
    
    
    //Mark: UITextFieldDelegate
    var oldNumber = ""
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        if textField == phoneNumber {
            textField.addTarget(self, action: #selector(applyMaskToPhoneField(_:)), forControlEvents: .EditingChanged)
        }
        
        if textField == phoneNumber || textField == clothesSize || textField == height {
            let invalidCharacters = NSCharacterSet(charactersInString: "+()-0123456789").invertedSet
            return string.rangeOfCharacterFromSet(invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
        }
        
        return false //для полей, у которых делегатом выставлен этот класс нельзя никаких значений заполнить по умолчанию
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == phoneNumber {
            if textField.text?.characters.count < 3 {
                textField.text = "+7"
                oldNumber = textField.text!
            }
        }
        
    }
    
    func applyMaskToPhoneField(textField: UITextField) {
        let count = textField.text?.characters.count
        if count < 3 {
            textField.text = "+7"
        }
        if oldNumber.characters.count < textField.text?.characters.count {
             //если символов меньше - цифры номера добавляются, нужно применять форматирование
            if let text = textField.text {
                if count == 3 {
                    let result = String(format: "%@(%@",
                                        text.substringToIndex(text.startIndex.advancedBy(2)),
                                        text.substringWithRange(text.startIndex.advancedBy(2) ... text.startIndex.advancedBy(2)))
                    textField.text = result
                    oldNumber = result
                }
                if count == 7 {
                    let result = String(format: "%@)%@",
                                    text.substringToIndex(text.startIndex.advancedBy(6)),
                                    text.substringWithRange(text.startIndex.advancedBy(6) ... text.startIndex.advancedBy(6)))
                    textField.text = result
                    oldNumber = result
                }
                if count == 11 {
                    let result = String(format: "%@-%@",
                                        text.substringToIndex(text.startIndex.advancedBy(10)),
                                        text.substringWithRange(text.startIndex.advancedBy(10) ... text.startIndex.advancedBy(10)))
                    textField.text = result
                    oldNumber = result
                }
                if count == 14 {
                    let result = String(format: "%@-%@",
                                        text.substringToIndex(text.startIndex.advancedBy(13)),
                                        text.substringWithRange(text.startIndex.advancedBy(13) ... text.startIndex.advancedBy(13)))
                    textField.text = result
                    oldNumber = result
                }
                if count > 16 {
                    let result = String(format: "%@",
                                        text.substringToIndex(text.startIndex.advancedBy(count!-1)))
                    textField.text = result
                    oldNumber = result
                }
                
                
            }
        }
        else if oldNumber.characters.count > textField.text?.characters.count {
            //если символов больше - цифры удаляются, нужно отменять форматирование
            if let text = textField.text {
                if count == 3 || count == 7 || count == 11 || count == 14{
                    let result = String(format: "%@",
                                        text.substringToIndex(text.startIndex.advancedBy(count!-1)))
                    textField.text = result
                    oldNumber = result
                }
            }
        }
    }
    
    func removeInvalidCharacters(s: String, charactersString: String) -> String {
        let invalidCharactersSet = NSCharacterSet(charactersInString: charactersString).invertedSet
        return s.componentsSeparatedByCharactersInSet(invalidCharactersSet).joinWithSeparator("")
    }
}