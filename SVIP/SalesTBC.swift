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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setupView() {
    let vc1 = ChatTVC()
    vc1.tabBarItem.image = UIImage(named: "ic_home")
    vc1.tabBarItem.title = "聊天"
    let nv1 = BaseNC()
    nv1.viewControllers = [vc1]
    
    let vc2 = MailListTVC()
    vc2.tabBarItem.title = "通讯录"
    vc2.tabBarItem.image = UIImage(named: "ic_dingdan")
    let nv2 = BaseNC()
    nv2.viewControllers = [vc2]
    
    let vc3 = FindListTVC()
    vc3.tabBarItem.title = "发现"
    vc3.tabBarItem.image = UIImage(named: "ic_duihua_b")
    let nv3 = BaseNC()
    nv3.viewControllers = [vc3]
    
    viewControllers = [nv1, nv2, nv3]
    
    tabBar.tintColor = UIColor(hexString: "#ff9800")
  }
  
}
