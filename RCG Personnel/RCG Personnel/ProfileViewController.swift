//
//  ProfileViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 25.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class ProfileViewController : BaseViewController {
 
    var authenticationManager = AuthenticationManager()
    
    @IBAction func logOffButtonPressed(sender: UIButton) {
        //Показать алерт - "Вы уверены?"
        //Очистить данные о пользователе - все токены и пр
        //Перейти на NewsViewController
        //Презентовать LoginViewController
        authenticationManager.logoff(self.tabBarController!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "E ", style: .Plain, target: nil, action: nil)
    }
    
    
    
}