//
//  TWShareManager.swift
//  RCG Personnel
//
//  Created by iFoxxy on 17.08.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit

final class TWShareManager: BaseShareManager {
    
    func share(text: String, image: UIImage?, url: NSURL) {
        Fabric.with([Twitter.self])
        
        let composer = TWTRComposer()
        
        composer.setURL(url)
        composer.setText(text)
        
        if image != nil {
            composer.setImage(image)
        }
        
        if parentViewController != nil {
            composer.showFromViewController(parentViewController!) { result in
                
                switch result {
                case .Cancelled:
                    print("Tweet composition cancelled")
                case .Done:
                    print("Tweet composition succeed")
                }
            }
        }
        else
        {
            print("parentViewController is nil")
        }
        
    }
}
