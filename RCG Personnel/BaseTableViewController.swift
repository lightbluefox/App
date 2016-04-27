//
//  BaseTableViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 21.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class BaseTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "P ", style: .Plain, target: self, action: "showProfile")
    }
    
    func showProfile() {
        if let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Profile")
        {
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
}