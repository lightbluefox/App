//
//  NewsViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 18.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Убираем прозрачность таббара и навбара
        self.navigationItem.title = "НОВОСТИ";
        self.navigationController?.navigationBar.translucent = false;
        self.tabBarController?.tabBar.translucent = false;
        }
}
