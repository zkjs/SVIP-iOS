//
//  OrderListHeaderView.swift
//  SVIP
//
//  Created by Hanton on 6/29/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class OrderListHeaderView: UIView {
  
  class func view() -> UIView {
    return NSBundle.mainBundle().loadNibNamed("OrderListHeaderView", owner: nil, options: nil)[0] as! UIView
  }
  
  class func height() -> CGFloat {
    return 600
  }
  
}
