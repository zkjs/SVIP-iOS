//
//  BookDateButton.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/6.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookDateButton: UIButton {

  var baseTitle: String!
  var date: NSDate? {
    didSet {
      let formatter = NSDateFormatter()
      formatter.dateFormat = "yyyy年MM月dd日"
      let titleStr = "\(baseTitle)：   \(formatter .stringFromDate(date!))"
      self .setTitle(titleStr, forState: UIControlState.Normal)
    }
  }
  
  var dateString: String? {
    get {
      let formatter = NSDateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      let str: String?
      if let myDate = self.date {
        return formatter .stringFromDate(myDate)
      }else {
        return nil
      }
    }
  }
  
  override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
    var rect = super.imageRectForContentRect(contentRect)
    rect.origin.x = contentRect.width - rect.width
    return rect
  }

}
