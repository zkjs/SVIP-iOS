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
      
      let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_tianjia"), style: UIBarButtonItemStyle.Plain, target: self, action: "add:")
       rightBarButtonItem.tintColor = UIColor.ZKJS_mainColor()
      super.navigationItem.rightBarButtonItems = [rightBarButtonItem]
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
    }


  




