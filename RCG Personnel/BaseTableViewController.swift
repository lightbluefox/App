//
//  BaseTableViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 21.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class BaseTableViewController: UITableViewController {

    let authenticationService = AuthenticationServiceImpl.sharedInstance    // TODO: DI
    let user = AuthenticationServiceImpl.sharedInstance.currentUser // TODO: выпилить
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        //Чтобы обновить картину кнопки в баре, если пользователь был загружен после того, как прогрузилась вьюха
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTableViewController.setBarButtons), name: NSNotificationCenterKeys.notifyThatUserHaveBeenUpdated, object: nil)
        
        setBarButtons()
    }
    
    func showProfile() {
        switch authenticationService.authenticationStatus {
        case .Authenticated:
            if let profileViewController = storyboard?.instantiateViewControllerWithIdentifier("Profile") {
                navigationController?.pushViewController(profileViewController, animated: true)
            }
        case .Unauthenticated, .Intermediate /* по идее при Intermediate надо открыть экран регистрации */:
            if let loginViewController = storyboard?.instantiateViewControllerWithIdentifier("Login") {
                navigationController?.presentViewController(loginViewController, animated: true, completion: nil)
            }
        }
    }
    
    func setBarButtons() {
        
        let profileButton = UIButton(type: .Custom)
        profileButton.bounds = CGRectMake(0, 0, 30, 30)
        profileButton.addTarget(self, action: #selector(BaseTableViewController.showProfile), forControlEvents: .TouchUpInside)
        profileButton.setImage(UIImage(named: "nophoto_user"), forState: .Normal)
        
        if let photoUrl = authenticationService.currentUser?.photoUrl.flatMap({ NSURL(string: $0) }) {
            profileButton.setImage(url: photoUrl, forState: .Normal)
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

extension UIButton {
    
    func setImage(url url: NSURL, forState state: UIControlState, completion: (() -> ())? = nil) {
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { [weak self] in
            let data = NSData(contentsOfURL: url)
            let image = data.flatMap { UIImage(data: $0) }
            
            dispatch_async(dispatch_get_main_queue()) {
                self?.setImage(image, forState: .Normal)
                completion?()
            }
        }
    }
}