//
//  SingleVacancyViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 23.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class SingleVacancyViewController: UIViewController {
    
    @IBOutlet weak var vacImageVIew: UIImageView!
    @IBOutlet weak var vacancyFemaleImage: UIImageView!
    
    @IBOutlet weak var vacancyCircle: UIImageView!
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
    @IBOutlet weak var vacReplyButton: UIButton!
    
    var vacGuid: String?
    
    let vacReceiver = VacanciesReceiver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ЛЕНТА ВАКАНСИЙ"
                
        //MARK: используя MBProgressHUD делаем экран загрузки, пока подгружается вакансия
        let loadingNotification = self.showLoadingNotification()
        self.vacReceiver.getSingleVac(self.vacGuid!, completionHandlerNews: { (success: Bool, result: String) in
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
    
    private func showLoadingNotification() -> AnyObject {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4);
        loadingNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
        loadingNotification.labelText = "Загрузка"
        
        return loadingNotification
    }
    
    private func setupButtonBack() {
        let buttonBack: UIButton = UIButton(type: .Custom);
        buttonBack.frame = CGRectMake(0, 0, 40, 40)
        buttonBack.setImage(UIImage(named: "backArrow"), forState: .Normal);
        buttonBack.setImage(UIImage(named: "backArrowSelected"), forState: UIControlState.Highlighted)
        buttonBack.addTarget(self, action: "leftNavButtonClick:", forControlEvents: UIControlEvents.TouchUpInside);
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonBack);
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false);
    }
    
    private func setupVacancyFields() {
        //MARK: получаем только первую фотку из массива, т.к. требований к нескольким фотографиям еще не было
        self.vacImageVIew.sd_setImageWithURL(NSURL(string: self.vacReceiver.singleVacancy.images[0]))
        self.vacDateDay.text = self.vacReceiver.singleVacancy.validTillDate.formatedDateDDMMYY.dayFromDdMmYyyy
        self.vacDateMonthYear.text = self.vacReceiver.singleVacancy.validTillDate.formatedDateDDMMYY.monthYearFromDdMmYyyy
        self.vacTitle.text = self.vacReceiver.singleVacancy.topic
        self.vacShortText.text = self.vacReceiver.singleVacancy.shortText
        self.vacFullText.text = self.vacReceiver.singleVacancy.fullText
        self.vacMoney.text = self.vacReceiver.singleVacancy.money
        
        switch self.vacReceiver.singleVacancy.sex {
        case "male" : self.vacancyFemaleImage?.image = UIImage(named: "femaleLightGray"); self.vacancyMaleImage?.image = UIImage(named: "maleRed");
        case "female" : self.vacancyFemaleImage?.image = UIImage(named: "femaleRed"); self.vacancyMaleImage?.image = UIImage(named: "maleLightGray");
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
        self.vacImageVIew.layer.cornerRadius = 75
        
        //MARK: Make it gray and blured
        //self.addBluredGrayBackground()
        
        
        self.vacReplyButton.backgroundColor = UIColor(red: 194/255, green: 0, blue: 18/255, alpha: 1.0)
        self.vacReplyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.vacReplyButton.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        //self.vacReplyButton.titleLabel?.font = UIFont(name: "Roboto Regular", size: 13)
        //self.vacReplyButton.setTitle("ХОЧУ РАБОТАТЬ", forState: UIControlState.Normal)
        
        self.separator.image = UIImage(named: "verticalSeparator")
        
        self.vacancyTopBackgroundImage.image = UIImage(named: "vacancyBackGround")
        self.vacancyCircle.image = UIImage(named: "vacancyPersCircle")
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
