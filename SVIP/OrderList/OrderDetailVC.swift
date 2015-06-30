//
//  OrderDetailVC.swift
//  SVIP
//
//  Created by Hanton on 6/29/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class OrderDetailVC: UIViewController {
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("OrderDetailVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "订单详情"
  }
  
}
