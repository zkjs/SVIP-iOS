//
//  CityVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/14.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class CityVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      title = "长沙"
      let item1 = UIBarButtonItem(image: UIImage(named: "ic_fanhui"), style: UIBarButtonItemStyle.Plain, target: self, action: "popTotopView:")
      self.navigationItem.leftBarButtonItem = item1
      
      let item2 = UIBarButtonItem(image: UIImage(named: "ic_sousuo"), style: UIBarButtonItemStyle.Plain, target: self, action: "search:")
      let item3 = UIBarButtonItem(image: UIImage(named: "ic_tianjia"), style: UIBarButtonItemStyle.Plain, target: self, action: "more:")
      navigationItem.setRightBarButtonItems([item3,item2], animated: true)
      
      navigationController?.navigationBar.translucent = false
      navigationController?.navigationBar.barStyle = UIBarStyle.Black
      navigationController?.navigationBar.tintColor = UIColor.whiteColor()
      

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  
  func popTotopView(sender:UIBarButtonItem) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  func search(sender:UIBarButtonItem) {
    
  }
  
  func more(sender:UIBarButtonItem) {
    
  }
  
    



}
