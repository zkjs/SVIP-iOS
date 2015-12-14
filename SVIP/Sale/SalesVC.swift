//
//  SalesVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/7.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class SalesVC: WMPageController{

    override func viewDidLoad() {
        super.viewDidLoad()
      navigationController?.navigationBar.translucent = false
      let rightBarButtonItem1 = UIBarButtonItem(image: UIImage(named: "sl_dengdai"), style: UIBarButtonItemStyle.Plain, target: self, action: "search:")
    super.navigationItem.rightBarButtonItem = rightBarButtonItem1
      
      let rightBarButtonItem2 = UIBarButtonItem(image: UIImage(named: "ic_tianjia"), style: UIBarButtonItemStyle.Plain, target: self, action: "add:")
      super.navigationItem.rightBarButtonItem = rightBarButtonItem2
      let leftBarButtonItem = UIBarButtonItem(title: "服务中心", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
      navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("SalesVC", owner:self, options:nil)
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.navigationBarHidden = false
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    //self.hidesBottomBarWhenPushed = true
  }
  
  func add(sender:UIBarButtonItem) {
    
  }
  
  func search(sender:UIBarButtonItem) {
    
  }
  
    }


  




