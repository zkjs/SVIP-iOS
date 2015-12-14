//
//  BaseNC.swift
//  SVIP
//
//  Created by Hanton on 11/6/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class BaseNC: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    navigationBar.barTintColor = UIColor.blackColor()
    navigationBar.translucent = true
    navigationBar.tintColor = UIColor.ZKJS_mainColor()
    navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.ZKJS_textColor()]
    
  }
  
//  override func preferredStatusBarStyle() -> UIStatusBarStyle {
//    return .LightContent
//  }
  
}
