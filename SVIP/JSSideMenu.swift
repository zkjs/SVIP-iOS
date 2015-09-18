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
    if self.contentViewController != nil {
      let navi = self.contentViewController as! UINavigationController
      let vc = navi.viewControllers.last!
      if vc.isKindOfClass(MainVC) {
        return UIStatusBarStyle.LightContent
      }
    }
    return UIStatusBarStyle.Default
  }
  
}
