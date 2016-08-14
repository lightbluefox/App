//
//  ProfileViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 25.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

final class ProfileViewController : BaseViewController {
 
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var agesLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var medicalBookNumber: UILabel!
    @IBOutlet weak var metroLabel: UILabel!
    @IBOutlet weak var passportLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var maleImageView: UIImageView!
    @IBOutlet weak var femaleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.prepareViewWithUpdatedUserProperties), name: NSNotificationCenterKeys.notifyThatUserHaveBeenUpdated, object: nil)
        
        prepareViewStyle()
        prepareViewWithUpdatedUserProperties()
    }
    
    override func setBarButtons() {
        let profileButton = UIButton(type: .Custom)
        profileButton.bounds = CGRectMake(0, 0, 41, 41)
        profileButton.addTarget(self, action: #selector(ProfileViewController.showEditProfileViewController), forControlEvents: .TouchUpInside)
        profileButton.setImage(UIImage(named: "editIcon"), forState: .Normal)
        let button = UIBarButtonItem(customView: profileButton)
        
        //Костыль, чтобы убрать большой отступ у кнопки профиля http://stackoverflow.com/questions/6021138/how-to-adjust-uitoolbar-left-and-right-padding
        let negativeSeparator = UIBarButtonItem.init(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSeparator.width = -15
        self.navigationItem.setRightBarButtonItems([negativeSeparator, button], animated: false)
    }
    
    func showEditProfileViewController() {
        self.navigationController?.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EditProfile"), animated: false)
    }
    
    func prepareViewWithUpdatedUserProperties() {
        //Prepare view
        nameLabel.text = user?.fullName?.uppercaseString
        phoneLabel.text = formatPhone(user?.phone ?? "", "%@(%@)%@-%@-%@")
        mailLabel.text = user?.email
        agesLabel.text = "Возраст: " + (user?.age ?? "0")
        heightLabel.text = "Рост: " + String(user?.height ?? 0)
        sizeLabel.text = "Размер одежды: " + String(user?.size ?? 0)
        medicalBookNumber.text = "Мед. книжка: " + (user?.medicalBookNumber ?? "")
        metroLabel.text = "Метро: " + (user?.metroStation ?? "")
        passportLabel.text = "Паспорт: " + (user?.passportData ?? "")
        if let photoUrl = NSURL(string: user?.photoUrl ?? "") {
            if UIApplication.sharedApplication().canOpenURL(photoUrl) {
                userPhotoImageView.sd_setImageWithPreviousCachedImageWithURL(NSURL(string: user?.photoUrl ?? ""), andPlaceholderImage: user?.noPhotoImage, options: .RetryFailed, progress: nil, completed: nil)
            }
            else
            {
                if let decodedFromBase64Image = user?.photoUrl?.decodeUIImageFromBase64() {
                    userPhotoImageView.image = decodedFromBase64Image
                }
            }
        }
        else {
            userPhotoImageView.image = user?.noPhotoImage
        }
        userPhotoImageView.clipsToBounds = true
        userPhotoImageView.contentMode = .ScaleAspectFill
        userPhotoImageView.layer.cornerRadius = 10
        
        if let gender = user?.gender {
            switch gender {
            case .Male:
                self.maleImageView.image = UIImage(named: "maleRed")
                self.femaleImageView.image = UIImage(named: "femaleGray")
            case .Female:
                self.maleImageView.image = UIImage(named: "maleGray")
                self.femaleImageView.image = UIImage(named: "femaleRed")
            }
        }
    }
    
    func prepareViewStyle() {
        self.title = "МОЯ АНКЕТА"
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "leftBackGround")!)
    }
    
    func formatPhone(s: String, _ mask: String) -> String {
        if s.characters.count == 11 {
            let result = String(format: mask, s.substringToIndex(s.startIndex.advancedBy(1)),
                                    s.substringWithRange(s.startIndex.advancedBy(1) ... s.startIndex.advancedBy(3)),
                                    s.substringWithRange(s.startIndex.advancedBy(4) ... s.startIndex.advancedBy(6)),
                                    s.substringWithRange(s.startIndex.advancedBy(7) ... s.startIndex.advancedBy(8)),
                                    s.substringWithRange(s.startIndex.advancedBy(9) ... s.startIndex.advancedBy(10))
                )
                return result
            }
        else {
            return s
        }
    }
}