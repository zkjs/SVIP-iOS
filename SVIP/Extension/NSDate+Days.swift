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
    calendar.rangeOfUnit(NSCalendarUnit.DayCalendarUnit, startDate: &startingDate, interval: nil, forDate: fromDate)
    calendar.rangeOfUnit(NSCalendarUnit.DayCalendarUnit, startDate: &resultDate, interval: nil, forDate: toDate)
    let dateComponets = calendar.components(NSCalendarUnit.DayCalendarUnit, fromDate: startingDate!, toDate: resultDate!, options: NSCalendarOptions.allZeros)
    return dateComponets.day
  }
}
