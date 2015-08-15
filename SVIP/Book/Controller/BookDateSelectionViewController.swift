//
//  BookDateSelectionViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/15.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookDateSelectionViewController: UIViewController, TSQCalendarViewDelegate {
  var startDate: NSDate?
  var endDate: NSDate?
  override func viewDidLoad() {
    super.viewDidLoad()
    initSubviews()
  }

  func initSubviews() {
    let calendarView = TSQCalendarView(frame: self.view.bounds)
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
      println("selection is over")
      self.navigationController?.popViewControllerAnimated(true)
    }
  }
}

