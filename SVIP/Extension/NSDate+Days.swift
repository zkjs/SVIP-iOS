//
//  NSDate+Days.swift
//  SVIP
//
//  Created by Hanton on 8/19/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import Foundation

extension NSDate {
  
  class func daysFromDate(fromDate: NSDate, toDate: NSDate) -> Int {
    var startingDate: NSDate? = nil
    var resultDate: NSDate? = nil
    let calendar = NSCalendar.currentCalendar()
    calendar.rangeOfUnit(.Day, startDate: &startingDate, interval: nil, forDate: fromDate)
    calendar.rangeOfUnit(.Day, startDate: &resultDate, interval: nil, forDate: toDate)
    let dateComponets = calendar.components(.Day, fromDate: startingDate!, toDate: resultDate!, options: NSCalendarOptions())
    return dateComponets.day
  }
  
  class func daysFromDateString(fromDateString: String, toDateString: String) -> Int {
    let dateFormat = NSDateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let fromDate = dateFormat.dateFromString(fromDateString) else { return 0 }
    guard let toDate = dateFormat.dateFromString(toDateString) else { return 0}
    var startingDate: NSDate? = nil
    var resultDate: NSDate? = nil
    let calendar = NSCalendar.currentCalendar()
    calendar.rangeOfUnit(.Day, startDate: &startingDate, interval: nil, forDate: fromDate)
    calendar.rangeOfUnit(.Day, startDate: &resultDate, interval: nil, forDate: toDate)
    let dateComponets = calendar.components(.Day, fromDate: startingDate!, toDate: resultDate!, options: NSCalendarOptions())
    return dateComponets.day
  }
  
}
