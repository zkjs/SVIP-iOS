//
//  MainTBC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/4.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MainTBC: UITabBarController {
  
  var heightDifference:CGFloat!
  var  isUnSelected = false
  let vc = FloatingWindowVC()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()
    
    //首页
    let vc1 = HomeVC()
    let nc1 = BaseNC(rootViewController: vc1)
    let image1 = UIImage(named: "ic_shouye_nor")
    vc1.tabBarItem.image = image1
    vc1.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
    
    //酒店餐饮休闲
    let vc2 = ComprehensiveVC()
    let nc2 = BaseNC(rootViewController: vc2)
    vc2.tabBarItem.image = UIImage(named: "ic_jiudian_nor")
    vc2.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
    
    //服务中心
    let vc3 = SalesVC()
    let nc3 = BaseNC(rootViewController: vc3)
    let titles = ["聊天","通讯录"]
    let vcClasses: [UIViewController.Type] = [ConversationListController.self, MailListTVC.self]
    vc3.menuItemWidth = 60
    vc3.menuViewStyle = WMMenuViewStyleLine
    vc3.titleSizeSelected = 15.0
    vc3.pageAnimatable = true
    vc3.progressColor = UIColor.ZKJS_mainColor()
    vc3.viewControllerClasses  = vcClasses
    vc3.titles = titles
    vc3.tabBarItem.image = UIImage(named: "ic_xiaoxi_nor")
    vc3.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
    
    //我的设置
    let vc4 = SettingVC()
    let nc4 = BaseNC(rootViewController: vc4)
    vc4.tabBarItem.image = UIImage(named: "ic_wo")
    vc4.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
    
    viewControllers = [nc1, nc2, nc3, nc4]
    tabBar.tintColor = UIColor.ZKJS_mainColor()
  }
  
  override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    
  }
  
}
