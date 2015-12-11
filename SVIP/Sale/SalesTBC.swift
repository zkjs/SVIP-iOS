//
//  SalesTBC.swift
//  SVIP
//
//  Created by Hanton on 11/16/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class SalesTBC: UIViewController {
 
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
  }
  
  func setupView() {
    
    
//    let vc1 = ConversationListController()
//    vc1.tabBarItem.title = "聊天"
//    vc1.tabBarItem.image = UIImage(named: "ic_liaotian_nor")
//    
//    let vc2 = MailListTVC()
//    vc2.tabBarItem.title = "通讯录"
//    vc2.tabBarItem.image = UIImage(named: "ic_tongxunlu_nor")
//    
//    let vc3 = FindListTVC()
//    vc3.tabBarItem.title = "发现"
//    vc3.tabBarItem.image = UIImage(named: "ic_faxian_nor")
//    
//    viewControllers = [vc1, vc2, vc3]
//    
//    tabBar.tintColor = UIColor.hx_colorWithHexString("#ff9800")
//    
//    view.backgroundColor = UIColor.whiteColor()
    
//    let vcClasses: [UIViewController.Type] = [ConversationListController.self, MailListTVC.self]
//    let pageController = WMPageController(viewControllerClasses: vcClasses, andTheirTitles: Titles)
//    pageController.pageAnimatable = true
//    pageController.menuViewStyle = WMMenuViewStyleLine
//    pageController.bounces = true
//    pageController.menuHeight = 35.0
//    pageController.titleSizeSelected = 15
//    pageController.values = titles // pass values
//    pageController.keys = ["type", "text"] // keys
//    pageController.title = "Test"
//    pageController.menuBGColor = .whiteColor()
  
    
  }
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.navigationBarHidden = false
  }
  
  func p_defaultController() -> WMPageController{
    let vcClasses: [UIViewController.Type] = [FindListTVC.self,MailListTVC.self]
    let Titles = ["聊天","通讯录"]
    let pageController = WMPageController(viewControllerClasses:vcClasses, andTheirTitles:Titles)
    pageController.pageAnimatable = true
    pageController.menuViewStyle = WMMenuViewStyleDefault
    pageController.bounces = true
    pageController.menuHeight = 35.0
    pageController.titleSizeSelected = 15
    pageController.values = ["Hello", "I'm Mark"] // pass values
    pageController.keys = ["type", "text"] // keys
    pageController.title = "Test"
    pageController.menuBGColor = .whiteColor()
    return pageController
  }
  
  
  
  // MARK: - UITabBarControllerDelegate
  
 
  
}

