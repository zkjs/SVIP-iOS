//
//  LoginManager.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/7.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class LoginManager: NSObject {
  var appWindow: UIWindow!
  class func sharedInstance() -> LoginManager {
    struct Singleton {
      static let instance = LoginManager()
    }
    return Singleton.instance
  }
  
  //进场动画
  func showAnimation() {
     appWindow.rootViewController = JSHAnimationVC()
  }
  //动画结束
  func afterAnimation() {
    if JSHAccountManager.sharedJSHAccountManager().userid != nil {//已注册
      showResideMenu(haspushed: nil)
    }else {//未注册
      showRegister()
    }
  }
  
  func showResideMenu(haspushed pushedVC: UIViewController?) {
    let nc = UINavigationController(rootViewController: MainVC())
    if pushedVC != nil {
      nc.pushViewController(pushedVC!, animated: false)
    }
    nc.navigationBarHidden = true
    let menu = RESideMenu(contentViewController: nc, leftMenuViewController: LeftMenuTVC(), rightMenuViewController: BookHotelListTVC())
    menu.contentViewScaleValue = 1
    menu.contentViewInPortraitOffsetCenterX = appWindow.bounds.size.width * (0.75 - 0.5)
    appWindow.rootViewController = menu

  }
  
  func showRegister() {
    appWindow.rootViewController = JSHHotelRegisterVC()
  }
}
