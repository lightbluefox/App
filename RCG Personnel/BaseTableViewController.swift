//
//  BaseTableViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 21.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class BaseTableViewController: UITableViewController {
    
    let user = User.sharedUser
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        //Чтобы обновить картину кнопки в баре, если пользователь был загружен после того, как прогрузилась вьюха
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewController.setBarButtons), name: NSNotificationCenterKeys.notifyThatUserHaveBeenUpdated, object: nil)
        
        setBarButtons()
    }
    
    func showProfile() {
        if user.isAuthenticated {
            if let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Profile")
            {
                self.navigationController?.pushViewController(profileViewController, animated: true)
            }
        }
        else {
            if let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as? LoginViewController {
                
                self.navigationController?.presentViewController(loginViewController, animated: true, completion: nil)
            }
        }
    }
    
    func setBarButtons() {
        
        let profileButton = UIButton(type: .Custom)
        profileButton.bounds = CGRectMake(0, 0, 30, 30)
        profileButton.addTarget(self, action: #selector(BaseTableViewController.showProfile), forControlEvents: .TouchUpInside)
        profileButton.setImage(user.noPhotoImage, forState: .Normal)
        if let photoUrlString = user.photoUrl {
            if let photoUrl = NSURL(string: photoUrlString) {
                if UIApplication.sharedApplication().canOpenURL(photoUrl) {
                    let imageview = UIImageView()
                    imageview.sd_setImageWithPreviousCachedImageWithURL(photoUrl, andPlaceholderImage: user.noPhotoImage, options: .RetryFailed, progress: nil, completed: nil)
                    profileButton.setImage(imageview.image, forState: .Normal)
                }
                else
                {
                    if let decodedFromBase64Image = photoUrlString.decodeUIImageFromBase64() {
                        profileButton.setImage(decodedFromBase64Image, forState: .Normal)
                    }
                }
            }
        }
        let button = UIBarButtonItem(customView: profileButton)
        
        //Костыль, чтобы убрать большой отступ у кнопки http://stackoverflow.com/questions/6021138/how-to-adjust-uitoolbar-left-and-right-padding
        let negativeSeparator = UIBarButtonItem.init(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSeparator.width = -5
        self.navigationItem.setRightBarButtonItems([negativeSeparator, button], animated: false)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}