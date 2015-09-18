//
//  LogManager.swift
//  SVIP
//
//  Created by Hanton on 7/13/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class LogManager: NSObject {
  
  class func sharedInstance() -> LogManager {
    struct Singleton {
      static let instance = LogManager()
    }
    return Singleton.instance
  }
  
  func logsDirectory() -> String {
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    let path = documentDirectory.stringByAppendingPathComponent("Logs")
    return path
  }
  
}
