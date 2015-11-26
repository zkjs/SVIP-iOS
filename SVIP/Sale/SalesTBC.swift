//
//  SalesTBC.swift
//  SVIP
//
//  Created by Hanton on 11/16/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class SalesTBC: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
  }
  
  func setupView() {
    title = "服务中心"
    
    let vc1 = ConversationListController()
    vc1.tabBarItem.title = "聊天"
    vc1.tabBarItem.image = UIImage(named: "ic_liaotian_nor")
    
    let vc2 = MailListTVC()
    vc2.tabBarItem.title = "通讯录"
    vc2.tabBarItem.image = UIImage(named: "ic_tongxunlu_nor")
    
    let vc3 = FindListTVC()
    vc3.tabBarItem.title = "发现"
    vc3.tabBarItem.image = UIImage(named: "ic_faxian_nor")
    
    viewControllers = [vc1, vc2, vc3]
    
    tabBar.tintColor = UIColor.hx_colorWithHexString("#ff9800")
    
    view.backgroundColor = UIColor.whiteColor()
  }
  
  // MARK: - UITabBarControllerDelegate
  
  override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    title = item.title
  }
  
}
