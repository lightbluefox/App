//
//  MenuViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 26.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class MenuViewController : BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 194/255, green: 0, blue: 18/255, alpha: 1.0)
        self.navigationItem.title = "МЕНЮ";
        self.navigationController?.navigationBar.translucent = false;
        self.tabBarController?.tabBar.translucent = false;
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = ""
        navigationItem.backBarButtonItem = backButtonItem
    }
}
