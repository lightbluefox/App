//
//  RegisterViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 30.05.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

final class RegisterViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var onFinish: (() -> ())?
    
    @IBAction func closeButtonTouched(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
    
    // TODO: переименовать все филды нормально (phoneNumberField, firstNameField и т.п.)
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
    @IBOutlet weak var SubwayStation: RCGTextFieldClass!    // TODO: с маленькой буквы
    @IBOutlet weak var passport: RCGTextFieldClass!
    
    private var gender = Gender.Male
    
    private let birthDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    @IBAction func registerButtonTouched(sender: AnyObject) {
        if fieldsAreValid.values.contains(false) {
            hudManager.showHUD("Ошибка", details: "Все поля обязательны для заполнения", type: .Failure)
        }
        else {
            let phone = phoneNumber.text.flatMap { removeInvalidCharacters($0, charactersString: "0123456789") } ?? ""
            
            let registrationParameters = RegistrationParameters(
                login: phone,
                firstName: firstName.text,
                lastName: lastName.text,
                middleName: middleName.text,
                email: email.text,
                gender: gender,
                dateOfBirth: birthDate.text.flatMap { birthDateFormatter.dateFromString($0) },
                height: height.text.flatMap { Int($0) },
                clothingSize: clothesSize.text.flatMap { Int($0) },
                metro: SubwayStation.text,
                passport: passport.text
            )
            
            weak var progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
            
            authenticationService.register(registrationParameters) { [weak self] result in
                guard let strongSelf = self else { return }
                
                progressHUD?.hide(true)
                
                switch result {
                
                case .Success:
                    guard let validatePhoneViewController = self?.storyboard?.instantiateViewControllerWithIdentifier("ValidatePhone") as? ValidatePhoneViewController else {
                        return assertionFailure("ValidatePhoneViewController not found")
                    }
                    
                    validatePhoneViewController.modalPresentationStyle = .OverFullScreen
                    validatePhoneViewController.phoneNumber = phone
                    validatePhoneViewController.onFinish = {
                        self?.onFinish?()
                    }
                    
                    self?.showDetailViewController(validatePhoneViewController, sender: self)
                    
                case .PhoneAlreadyRegistered:
                    self?.hudManager.showAlertWithСancelButton(
                        "Номер уже зарегистрирован",
                        message: "Выслать на него новый пароль?",
                        cancelButtonTitle: "Нет",
                        action: UIAlertAction(title: "Выслать", style: .Default) { _ in
                            self?.dismissViewControllerAnimated(true) {
                                //registerViewController?.parentViewController?.showViewController(<#T##vc: UIViewController##UIViewController#>, sender: <#T##AnyObject?#>)
                                //отобразить вью контроллер для восстановления пароля хотя мб достаточно отразить главный VC
                            }
                        }
                    )
                    
                case .Failed(let error):
                    MBProgressHUD.showError(error, inView: strongSelf.view)
                }
            }
            
            //authenticationManager.registerNewUser(self, user: User(photo: "https://lh5.googleusercontent.com/-MlnvEdpKY2w/AAAAAAAAAAI/AAAAAAAAAFw/x6wHNLJmtQ0/s0-c-k-no-ns/photo.jpg", firstName: "Иван", middleName: "Петрович", lastName: "Путинов", phone: self.phoneNumber.text ?? "", email: "mail@mail.ru", birthDate: "22.07.1912", height: 180, size: 42, hasMedicalBook: true, medicalBookNumber: "1231231", metroStation: "Севастопольская", passportData: "1231 312312", gender: .Male))
        }
    }
    
    @IBAction func editingDidEnd(sender: RCGTextFieldClass) {
        if sender.text != "" {
            sender.isValid = true
            print(fieldsAreValid.indexForKey(sender))
            print(fieldsAreValid.values)
            fieldsAreValid.updateValue(sender.isValid, forKey: sender)
        }
        else {
            sender.isValid = false
            fieldsAreValid.updateValue(sender.isValid, forKey: sender)
        }
        sender.setRightImage()
    }
    
    var fieldsAreValid = [UITextField : Bool]()
    var validationCode: String?
    var hudManager = HUDManager()
    let imagePicker = UIImagePickerController()
    var genderOptions: [Gender] = [.Male, .Female]
    let validatePhoneViewController = ValidatePhoneViewController()
    
    private let authenticationService: AuthenticationService = AuthenticationServiceImpl()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hudManager.parentViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fieldsAreValid = [
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
        scrollViewBottomMarginConstant = scrollViewBottomMargin.constant
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.CGRectValue()
                scrollViewBottomMargin.constant = scrollViewBottomMarginConstant + frame.size.height
                
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
        scrollViewBottomMargin.constant = scrollViewBottomMarginConstant
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
    
    //MARK: UIPickerViewDelegate
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row].localizedTitle
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        gender = genderOptions[row]
        sex.text = gender.localizedTitle
    }
    
    ///Создает PickerView с выбором пола, который открывается при тапе на TextField
    private func addGenderPickerViewOnTap(forTextField sender: UITextField) {
        let pickerView = UIPickerView.init(frame: CGRectMake(0, 50, 100, 150))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
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
        let selectedDate = birthDateFormatter.stringFromDate(datepicker.date)
        birthDate.text = selectedDate
    }
    
    //Mark: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        if textField == phoneNumber {
            textField.addTarget(self, action: #selector(applyMaskToPhoneField(_:)), forControlEvents: .EditingChanged)
        }
        
        if textField == phoneNumber || textField == clothesSize || textField == height {
            let invalidCharacters = NSCharacterSet(charactersInString: "0123456789").invertedSet
            return string.rangeOfCharacterFromSet(invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
        }
        
        return false //для полей, у которых делегатом выставлен этот класс нельзя никаких значений заполнить по умолчанию
    }
    
    func applyMaskToPhoneField(textField: UITextField) {
        func formatPhone(s: String, _ mask: String) -> String {
         let result = String(format: mask, s.substringToIndex(s.startIndex.advancedBy(1)),
         s.substringWithRange(s.startIndex.advancedBy(1) ... s.startIndex.advancedBy(3)),
         s.substringWithRange(s.startIndex.advancedBy(4) ... s.startIndex.advancedBy(6)),
         s.substringWithRange(s.startIndex.advancedBy(7) ... s.startIndex.advancedBy(8)),
         s.substringWithRange(s.startIndex.advancedBy(9) ... s.startIndex.advancedBy(10))
         )
         return result
         }
        
         //Для phoneNumber.
         //Форматируем после 11 знаков.
         //После 12 знаков форматирование убираем
         if textField == phoneNumber {
            if textField.text != "" {
                if textField.text?.characters.count == 11 {
                    textField.text = formatPhone(textField.text!, "%@(%@)%@-%@-%@")
                }
                else {
                    textField.text = removeInvalidCharacters(textField.text!, charactersString: "0123456789")
                }
            }
         }
    }
    func removeInvalidCharacters(s: String, charactersString: String) -> String {
        let invalidCharactersSet = NSCharacterSet(charactersInString: charactersString).invertedSet
        return s.componentsSeparatedByCharactersInSet(invalidCharactersSet).joinWithSeparator("")
    }
}