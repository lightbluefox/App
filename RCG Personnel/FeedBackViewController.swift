//
//  FeedBackViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 26.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class FeedBackViewController : BaseViewController, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var themeTextField: RCGTextFieldClass!
    @IBOutlet weak var nameTextField: RCGTextFieldClass!
    @IBOutlet weak var emailTextField: RCGTextFieldClass!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextRectangle: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    //Mark: константа для хранения значения нижнего отступа ScrollView
    var scrollViewBottomMarginConstant : CGFloat = 0
    
    var pickerData = [String]()
    
    @IBOutlet weak var scrollViewBottomMargin: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ОБРАТНАЯ СВЯЗЬ";
        self.navigationController?.navigationBar.translucent = false;
        self.tabBarController?.tabBar.translucent = false;
        
        nameTextField.autocapitalizationType = UITextAutocapitalizationType.Words
        emailTextField.keyboardType = UIKeyboardType.EmailAddress
        
        setShowingPickerViewOnTap(themeTextField)
        
        //MARK: Скрывать, клавиатуру при тапе по скрол вью
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard:");
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        setScrollViewSqueezeOnKeyboardAppearаnce()
        
    }
    
    private func setShowingPickerViewOnTap(sender: UITextField) {
        let pickerView = UIPickerView.init(frame: CGRectMake(0, 50, 100, 150))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        self.pickerData = ["Работа приложения", "Работа на акциях", "Предложения", "Другое"]
        sender.inputView = pickerView
        
        //Делегируем полю, чтобы в функции textField() запретить пользователям вставлять текст.
        sender.delegate = self
    }
    
    private func setScrollViewSqueezeOnKeyboardAppearаnce() {
        self.scrollViewBottomMarginConstant = self.scrollViewBottomMargin.constant;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
        messageTextView.textContainerInset = UIEdgeInsetsMake(8, 3, 8, 30)
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.cornerRadius = 5
        messageTextView.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.2).CGColor
        messageTextRectangle.selected = false;
        
        messageTextView.delegate = self
        messageTextView.text = "Текст сообщения *"
        messageTextView.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        
    }
    
    func keyboardWillShowNotification(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.CGRectValue()
                self.scrollViewBottomMargin.constant = self.scrollViewBottomMarginConstant + frame.size.height - 45//-45, т.к. над клавиатурой появляется широкий белый отступ.
                
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
    
    @IBAction func textFieldEditingDone(sender: UITextField) {
        if sender.text != "" {
            let imageView = UIImageView();
            imageView.image = UIImage(named: "textRectangleOk");
            imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 14);
            imageView.contentMode = UIViewContentMode.Left;
            sender.rightView = imageView;
        }
        else
        {
            let imageView = UIImageView();
            imageView.image = UIImage(named: "textRectangle");
            imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 14);
            imageView.contentMode = UIViewContentMode.Left;
            sender.rightView = imageView;
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if messageTextView.textColor == UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        {
            messageTextView.text = ""
            messageTextView.textColor = UIColor.darkGrayColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if messageTextView.text == ""
        {
            messageTextView.text = "Текст сообщения"
            messageTextView.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
            messageTextRectangle.selected = false
        }
        else
        {
            messageTextRectangle.selected = true
        }
        
    }
    
    @IBAction func submitButtonClick(sender: UIButton) {
        if messageTextView.textColor == UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1) || nameTextField.text == "" || emailTextField.text == "" || themeTextField.text == ""
        {
            let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
            failureNotification.mode = MBProgressHUDMode.CustomView
            failureNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3);
            //failureNotification.color = UIColor(red: 194/255, green: 0, blue: 18/255, alpha: 0.8);
            failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
            failureNotification.labelText = "Ошибка"
            failureNotification.detailsLabelText = "Все поля обязательны для заполнения"
            failureNotification.hide(true, afterDelay: 3)
        }
        else
        {
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            //loadingNotification.color = UIColor(red: 194/255, green: 0, blue: 18/255, alpha: 0.8);
            loadingNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
            loadingNotification.labelText = "Отправляем..."
            
            let request = HTTPTask();
            let requestUrl = Constants.apiUrl + "api/v01/feedback"
            let params: Dictionary<String,AnyObject> = ["name":nameTextField.text!, "email":emailTextField.text!, "text":messageTextView.text, "topic":themeTextField.text!];
            
            request.POST(requestUrl, parameters: params, completionHandler: {(response: HTTPResponse) in
                if let err = response.error {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        loadingNotification.hide(true)
                        
                        let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
                        failureNotification.mode = MBProgressHUDMode.CustomView
                        failureNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                        //failureNotification.color = UIColor(red: 194/255, green: 0, blue: 18/255, alpha: 0.8);
                        failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
                        failureNotification.labelText = "Ошибка"
                        failureNotification.detailsLabelText = err.localizedDescription
                        failureNotification.hide(true, afterDelay: 3)
                    }
                    print("error: " + err.localizedDescription)
                }
                else if let resp: AnyObject = response.responseObject {
                    _ = NSString(data: resp as! NSData, encoding: NSUTF8StringEncoding)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        loadingNotification.hide(true)
                        
                        let successNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
                        successNotification.mode = MBProgressHUDMode.CustomView
                        successNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                        let imageView = UIImageView();
                        imageView.image = UIImage(named: "checkmark");
                        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50);
                        imageView.contentMode = UIViewContentMode.Center;
                        successNotification.customView = imageView
                        
                        successNotification.hide(true, afterDelay: 3)
                        self.clearView()
                    }
                }
            })
        }
    }
    
    private func clearView() {
        messageTextView.text = "Текст сообщения"
        messageTextView.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        messageTextRectangle.selected = false
        nameTextField.text = ""
        textFieldEditingDone(nameTextField)
        themeTextField.text = ""
        textFieldEditingDone(themeTextField)
        emailTextField.text = ""
        textFieldEditingDone(emailTextField)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard(sender: AnyObject) {
        self.scrollView.endEditing(true)
    }
    
    func leftNavButtonClick(sender: UIButton!)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //Mark: UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    //MARK: UIPickerView
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        self.themeTextField.text = pickerData[row]
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
