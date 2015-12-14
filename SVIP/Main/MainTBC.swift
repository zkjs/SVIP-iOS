//
//  MainTBC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/4.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MainTBC: UITabBarController{
  var heightDifference:CGFloat!
  var  isUnSelected = false
  let vc = FloatingWindowVC()
  
      override func viewDidLoad() {
        super.viewDidLoad()
      view.backgroundColor = UIColor.whiteColor()
      
      //首页
      let vc1 = HomeVC()
      //let nc1 = BaseNC(rootViewController: vc1)
      let image1 = UIImage(named: "ic_shouye_nor")
      vc1.tabBarItem.image = image1
      vc1.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
      
      //酒店餐饮休闲
      let vc2 = ComprehensiveVC()
     // let nc2 = BaseNC(rootViewController: vc2)
        
      vc2.tabBarItem.image = UIImage(named: "ic_jiudian_nor")
      vc2.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
   
      //智键
//      let vc3 = UIViewController()
//      self.addCenterButtonWithImage(UIImage(named: "ic_zhijian"), highlightImage: nil)
//      self.button.addTarget(self, action: "press:", forControlEvents: UIControlEvents.TouchUpInside)
        
      //服务中心
      let vc4 = SalesVC()
    //  let nc4 = BaseNC(rootViewController: vc4)
      let titles = ["聊天","通讯录"]
      let vcClasses: [UIViewController.Type] = [ConversationListController.self, MailListTVC.self]
      vc4.menuItemWidth = 60
      vc4.menuViewStyle = WMMenuViewStyleLine
      vc4.titleSizeSelected = 15.0
      vc4.pageAnimatable = true
      vc4.progressColor = UIColor.hx_colorWithHexString("ffc56e")
      vc4.viewControllerClasses  = vcClasses
      vc4.titles = titles
      vc4.tabBarItem.image = UIImage(named: "ic_xiaoxi_nor")
      vc4.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
      //我的设置
      let vc5 = SettingVC()
    //  let nc5 = BaseNC(rootViewController: vc5)
      vc5.tabBarItem.image = UIImage(named: "ic_wo")
      vc5.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
      
      viewControllers = [vc1, vc2, vc4, vc5]
      tabBar.tintColor = UIColor.hx_colorWithHexString("ffc56e")
      

    }
  
  override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
//    if selectedIndex == 0 || selectedIndex == 3 {
//      navigationController?.navigationBarHidden = true
//    } else {
//      navigationController?.navigationBarHidden = false
//    }
    
    isUnSelected = false
    vc.view.removeFromSuperview()
  }
  
  func press(sender:UIButton) {
    
    isUnSelected = !isUnSelected
    if isUnSelected {
      vc.view.frame = CGRectMake(0.0, 0.0, view.frame.width, view.frame.height-50)
      self.view.addSubview(vc.view)
      self.addChildViewController(vc)

    }else {
      vc.view.removeFromSuperview()
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
}
