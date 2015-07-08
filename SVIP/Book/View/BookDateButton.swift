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
//    get {
//      return date
//    }
//    set {
//      let calendar = NSCalendar()
//      let components =
//    }
//    NSCalendar *calendar = self.datePicker.calendar;
//    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.datePicker.date];
//    NSDate *tempDate = [self.datePicker.calendar dateFromComponents:components];
    
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
      if date != nil {
        str = formatter .stringFromDate(date!)
        return str
      }else {
        return nil
      }
    }
  }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
