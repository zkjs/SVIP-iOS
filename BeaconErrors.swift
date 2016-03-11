//
//  BeaconErrors.swift
//  SVIP
//
//  Created by Qin Yejun on 3/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import CoreData


class BeaconErrors: NSManagedObject {

  static let kLastUploadTime = "kLastUploadTime"
  
  //最近一次上传错误日志时间
  static func getLastUploadTime() -> NSDate? {
    NSUserDefaults.standardUserDefaults()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    if let date = userDefaults.objectForKey(BeaconErrors.kLastUploadTime) as? NSDate {
      return date
    }
    return nil
  }
  
  //设置最近上传错误日志时间
  static func setLastUploadTime(date:NSDate) {
    NSUserDefaults.standardUserDefaults()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(date, forKey: BeaconErrors.kLastUploadTime)
    userDefaults.synchronize()
  }
  
  //
  static func uploadLogs() {
    //don't upload logs to the server if last upload time is within 24 hours
    if let lastUploadTime = BeaconErrors.getLastUploadTime() where fabs(lastUploadTime.timeIntervalSinceNow) < 24 * 3600 {
      return
    }
    
    if let allErrors = BeaconErrors.allWithOrder(["timestamp":"ASC"])  as? [BeaconErrors] {
      var logs : String = ""
      for e in allErrors {
        //print("\(e.timestamp)")
        guard let ts = e.timestamp else {
          e.remove()
          continue
        }
        logs = logs + "\(ts):\(e.error)"
        //print("remove:\(e.timestamp)")
        e.remove()
      }
      //TODO: send all logs to server here
      
      
      BeaconErrors.saveAllChanges()
    }
  }
  
}
