//
//  SingleVacancyViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 23.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import MBProgressHUD
import FBSDKShareKit
import Social
import Alamofire

class SingleVacancyViewController: BaseViewController, FBSDKSharingDelegate {
    
    @IBOutlet weak var vacImageVIew: UIImageView!
    var vacImage: UIImage? //сюда пишется фотография, после загрузки через URL, чтобы использовать ее потом наверняка для шаринга
    @IBOutlet weak var vacancyFemaleImage: UIImageView!
    @IBOutlet weak var vacancyTopBackgroundImage: UIImageView!
    @IBOutlet weak var vacancyMaleImage: UIImageView!
    @IBOutlet weak var vacValidTillLabel: UILabel!
    @IBOutlet weak var vacDateDay: UILabel!
    @IBOutlet weak var vacDateMonthYear: UILabel!
    
    @IBOutlet weak var vacTitle: UILabel!
    @IBOutlet weak var vacShortText: UILabel!
    @IBOutlet weak var vacMoney: UILabel!
    
    @IBOutlet weak var separator: UIImageView!
    @IBOutlet weak var vacFullText: UILabel!
    @IBOutlet weak var vacReplyButton: RCGButton!
    
    @IBAction func vacReplyButtonTouched(sender: AnyObject) {
    }
    @IBAction func vacShareVKButtonTouched(sender: AnyObject) {
 
        shareManager.share(to: .Vkontakte(text: "Появилась новая вакансия: \(vacTitle.text ?? "")\n\n\(vacShortText.text ?? "")\nСтавка: \(vacMoney.text ?? "")", image: vacImage, url: NSURL(string: Constants.appStoreUrl)!, urlTitle: "Больше вакансий"))
    }
    
    @IBAction func vacShareTWButtonTouched(sender: AnyObject) {
        
        shareManager.share(to: .Twitter(text: "Появилась новая вакансия: \(vacTitle.text ?? "")\n\n\(vacShortText.text ?? "")\nСтавка: \(vacMoney.text ?? "")", image: vacImage, url: NSURL(string: Constants.appStoreUrl)!))
    }
    
    @IBAction func vacShareFBButtonTouched(sender: AnyObject) {
        var imageUrl : NSURL?
        if !self.vacReceiver.singleVacancy.images.isEmpty {
            imageUrl = NSURL(string: self.vacReceiver.singleVacancy.images[0])
        }
        shareManager.share(to: .Facebook(title: "Появилась новая вакансия - \(vacTitle.text ?? "")", description: "Ставка: \(vacMoney.text ?? ""). \n\(vacShortText.text ?? "")", url: NSURL(string: Constants.appStoreUrl)!, imageURL: imageUrl))
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("Canceled")
    }
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("Completed")
    }
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("Failed")
        print(error.description)
    }
    
    var vacGuid: String?
    
    let vacReceiver = VacanciesReceiver()
    let hudManager = HUDManager()
    let shareManager = ShareManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareManager.vkShareManager.parentViewController = self
        self.shareManager.twShareManager.parentViewController = self
        self.shareManager.fbShareManager.parentViewController = self
        
        self.hudManager.parentViewController = self
        self.navigationItem.title = "ЛЕНТА ВАКАНСИЙ"
                
        reloadView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.reloadViewSilently), name: NSNotificationCenterKeys.notifyThatUserHaveBeenUpdated, object: nil)
    }
    
    func reloadView() {
        //MARK: используя MBProgressHUD делаем экран загрузки, пока подгружается вакансия
        let loadingNotification = self.showLoadingNotification()
        self.vacReceiver.getSingleVac(self.vacGuid!, completionHandlerVacs: { (success: Bool, result: String) in
            if success {
                self.setupVacancyFields()
                self.setupVacancyView()
                loadingNotification.hide(true)
            }
            else if !success {
                loadingNotification.hide(true)
                self.showFailureNotification(result)
            }
        })
    }
    
    func reloadViewSilently() {
        self.vacReceiver.getSingleVac(self.vacGuid!, completionHandlerVacs: { (success: Bool, result: String) in
            if success {
                self.setupVacancyFields()
                self.setupVacancyView()
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let count = self.navigationController?.viewControllers.count {
            let backButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
            let parentViewController = self.navigationController?.viewControllers[count - 2]
            parentViewController?.navigationItem.backBarButtonItem = backButtonItem
        }
    }
    
    private func showLoadingNotification() -> MBProgressHUD {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        loadingNotification.mode = .Indeterminate
        loadingNotification.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4);
        loadingNotification.label.font = UIFont(name: "Roboto Regular", size: 12)
        loadingNotification.label.text = "Загрузка"
        
        return loadingNotification
    }
    
    private func setupButtonBack() {
        let buttonBack: UIButton = UIButton(type: .Custom);
        buttonBack.frame = CGRectMake(0, 0, 40, 40)
        buttonBack.setImage(UIImage(named: "backArrow"), forState: .Normal);
        buttonBack.setImage(UIImage(named: "backArrowSelected"), forState: UIControlState.Highlighted)
        buttonBack.addTarget(self, action: #selector(SingleVacancyViewController.leftNavButtonClick(_:)), forControlEvents: UIControlEvents.TouchUpInside);
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonBack);
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false);
    }
    
    private func setupVacancyFields() {
        //MARK: получаем только первую фотку из массива, т.к. требований к нескольким фотографиям еще не было
        if self.vacReceiver.singleVacancy.images.isEmpty {
            self.vacImageVIew.image = UIImage(named: "noimage")
        }
        else {
            self.vacImageVIew.sd_setImageWithURL(NSURL(string: self.vacReceiver.singleVacancy.images[0])){
                (result) in
                self.vacImage = result.0
            }
        }
        
        self.vacDateDay.text = self.vacReceiver.singleVacancy.validTillDate.formatedDateDDMMYY.dayFromDdMmYyyy
        self.vacDateMonthYear.text = self.vacReceiver.singleVacancy.validTillDate.formatedDateDDMMYY.monthYearFromDdMmYyyy
        self.vacTitle.text = self.vacReceiver.singleVacancy.topic
        self.vacShortText.text = self.vacReceiver.singleVacancy.shortText
        self.vacFullText.text = self.vacReceiver.singleVacancy.fullText
        self.vacMoney.text = self.vacReceiver.singleVacancy.money
        
        switch self.vacReceiver.singleVacancy.sex {
        case "male" : self.vacancyFemaleImage?.image = UIImage(named: "femaleGray"); self.vacancyMaleImage?.image = UIImage(named: "maleRed");
        case "female" : self.vacancyFemaleImage?.image = UIImage(named: "femaleRed"); self.vacancyMaleImage?.image = UIImage(named: "maleGray");
        case "both" : self.vacancyFemaleImage?.image = UIImage(named: "femaleRed"); self.vacancyMaleImage?.image = UIImage(named: "maleRed");
        default : self.vacancyFemaleImage?.image = UIImage(named: "femaleRed"); self.vacancyMaleImage?.image = UIImage(named: "maleRed");
        }
    }
    
    private func setupVacancyView() {
        //MARK: Rotate the text
        self.vacValidTillLabel.text = "ЗАКРЫТИЕ НАБОРА"
        self.vacValidTillLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        
        //MARK: Make a circle
        self.vacImageVIew.clipsToBounds = true
        self.vacImageVIew.layer.cornerRadius = 10
        
        //MARK: Modify replyButton depending on user authentication: Gray, Red or Green
        //if nil - not authenticated, gray
        //if true - authenitcated, already replied, green
        //if false - authenticated, not replied, red
        if let replied = self.vacReceiver.singleVacancy.userReplied {
            switch replied {
            case true:
                self.vacReplyButton.setBackgroundColor(UIColor(red: 66/255, green: 186/255, blue: 97/255, alpha: 1.0), forUIControlState: UIControlState.Normal)
                self.vacReplyButton.setTitle("ЗАПРОС ОТПРАВЛЕН", forState: .Normal)
                self.vacReplyButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
                
            case false:
                self.vacReplyButton.setBackgroundColor(UIColor(red: 232/255, green: 76/255, blue: 61/255, alpha: 1.0), forUIControlState: .Normal)
                self.vacReplyButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
                self.vacReplyButton.addTarget(self, action: #selector(self.vacancyReply), forControlEvents: UIControlEvents.TouchUpInside)
                
            }
        }
        else {
            self.vacReplyButton.setBackgroundColor(UIColor.grayColor(), forUIControlState: UIControlState.Normal)
            self.vacReplyButton.addTarget(self, action: #selector(self.showHudThatUserIsNotAuthenticated), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        
        //MARK: Make it gray and blured
        //self.addBluredGrayBackground()
        
        
        //self.vacReplyButton.backgroundColor = UIColor(red: 194/255, green: 0, blue: 18/255, alpha: 1.0)
        //self.vacReplyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal) //в сториборде сд
        //self.vacReplyButton.setTitleColor(UIColor.whiteColor(), forState: .Selected)
 
        self.separator.image = UIImage(named: "verticalSeparator")
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "leftBackGround")!)
        //self.view.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1)
    }
    
    func vacancyReply() {
        NSLog("VacancyReplying(\(self.vacReceiver.singleVacancy.guid)). Started.")
        
        let hud = hudManager.showHUD("Отправляем отклик...", details: nil, type: .Processing)
        
        let requestUrl = Constants.apiUrl + "api/v01/vacancies/" + self.vacReceiver.singleVacancy.guid + "/replies"
        let headers = ["Authorization": "Bearer " + user.token ?? "", "Content-Type": "application/x-www-form-urlencoded"]
        
        
        Alamofire.request(.POST, requestUrl, headers: headers).responseString {response in
            switch response.result {
            case .Success:
                if let responseData = response.data {
                    var jsonError: NSError?
                    let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                    
                    if let error = json["error"].string {
                        self.hudManager.hideHUD(hud)
                        self.hudManager.showHUD("Ошибка", details: error, type: .Failure)
                        NSLog("VacancyReplying(\(self.vacReceiver.singleVacancy.guid)). Error. \(error)")
                    }
                    else {
                        self.hudManager.hideHUD(hud)
                        self.hudManager.showHUD("", details: "", type: .Success)
                        NSLog("VacancyReplying(\(self.vacReceiver.singleVacancy.guid)). Reply succeed. Reloading vacancy data...")
                        self.reloadViewSilently()
                        NSLog("VacancyReplying(\(self.vacReceiver.singleVacancy.guid)). Data reloaded. Finished.")
                        
                    }
                }
            case .Failure(let err):
                self.hudManager.hideHUD(hud)
                self.hudManager.showHUD("Ошибка", details: err.description, type: .Failure)
                NSLog("VacancyReplying(\(self.vacReceiver.singleVacancy.guid)). Error. \(err.description)")
            }
        }
    }
    
    func showHudThatUserIsNotAuthenticated() {
        hudManager.showHUD("Войдите в приложение", details: "Только авторизованные пользователи могут откликаться на вакансии.", type: .Failure)
    }
    
    private func showFailureNotification(result:String){
        let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        failureNotification.mode = MBProgressHUDMode.Text
        failureNotification.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4);
        failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
        failureNotification.labelText = "Ошибка"
        failureNotification.detailsLabelText = result
        failureNotification.hide(true, afterDelay: 3)
    }
    
    private func addBluredGrayBackground() {
        //MARK: Make it gray
        let image = self.vacImageVIew.image!
        let imageRect = CGRectMake(0,0,CGFloat(CGImageGetWidth(image.CGImage)),CGFloat(CGImageGetHeight(image.CGImage)))
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGBitmapContextCreate(nil, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage), 8, 0, colorSpace, CGBitmapInfo.ByteOrderDefault.rawValue)
        CGContextDrawImage(context, imageRect, image.CGImage)
        
        let imageRef = CGBitmapContextCreateImage(context)
        
        let backgroundImage = UIImage(CGImage: imageRef!, scale: CGFloat(CGImageGetWidth(image.CGImage))/image.size.width, orientation: UIImageOrientation.Up)
        
        
        //MARK: Create blur effect view
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        view.addSubview(blurEffectView)
        
        //MARK: Create background view
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = backgroundImage
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        view.addSubview(imageViewBackground);
        view.sendSubviewToBack(blurEffectView);
        view.sendSubviewToBack(imageViewBackground);
    }
    
    func leftNavButtonClick(sender: UIButton!)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        let vacancyResponseViewController = segue.destinationViewController as! VacancyResponseViewController
        
        // Pass the selected object to the new view controller.
        vacancyResponseViewController.vacancyId = vacGuid
        
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = ""
        navigationItem.backBarButtonItem = backButtonItem
    }

}
