//
//  BookDateSelectionViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/15.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

typealias SelectionBlock = (NSDate, NSDate) -> ()

class BookDateSelectionViewController: UIViewController, TSQCalendarViewDelegate {
  
  var selection: SelectionBlock?
  var startDate: NSDate?
  var endDate: NSDate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initSubviews()
  }

  func initSubviews() {
    let calendarView = TSQCalendarView(frame: view.bounds)
    calendarView.delegate = self;
    calendarView.firstDate = NSDate()
    calendarView.lastDate = NSDate(timeIntervalSinceNow: NSTimeInterval(60*60*24*60))
    calendarView.startDate = startDate
    calendarView.endDate = endDate
    self.view.addSubview(calendarView)
  }
  
  //MARK:- TSQCalendarViewDelegate
  func calendarView(calendarView: TSQCalendarView!, didSelectDate date: NSDate!) {
    if (calendarView.startDate != nil && calendarView.endDate != nil) {
      print("selection is over")
      if selection != nil {
        selection!(calendarView.startDate, calendarView.endDate)
      }
      // 延迟一秒，让用户看清楚离店时间动画
      let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime, dispatch_get_main_queue()) {
        self.navigationController?.popViewControllerAnimated(true)
      }
    }
  }
  
}

