//
//  JSSideMenu.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/31.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class JSSideMenu: RESideMenu {
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
//    if let nv = contentViewController as? UINavigationController {
//      if let vc = nv.viewControllers.last {
//        if vc.isKindOfClass(MainTVC) {
//          return .LightContent
//        }
//      }
//    }
    return .LightContent
  }
  
}
