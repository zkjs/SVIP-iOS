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

  static let kLastUploadTime = "kLogsLastUploadTime"
  static let kTotalCount = "kLogsTotalCount"
  static let kRetryCount = "kLogsRetryCount"
  
  //getUserId()+ "-" +time + "-" + timestamp + ".txt";
  static func fileName() -> String {
    let userid = TokenPayload.sharedInstance.userID ?? "0"
    let currentTime = NSDate()
    return userid + "-" + currentTime.formattedWith("yyyy-MM-dd-HH-mm-ss") + "-" + "\(Int(currentTime.timeIntervalSince1970))" + ".txt"
  }
  
  //最近一次上传错误日志时间
  static func getLastUploadTime() -> NSDate? {
    if let date = LocalStorage.objectForKey(BeaconErrors.kLastUploadTime) as? NSDate {
      return date
    }
    return nil
  }
  
  //设置最近上传错误日志时间
  static func setLastUploadTime(date:NSDate) {
    LocalStorage.setObject(date, forKey: BeaconErrors.kLastUploadTime)
  }
  
  static func addTotalCount() {
    if let cnt = LocalStorage.objectForKey(BeaconErrors.kTotalCount) as? Int {
      LocalStorage.setObject(cnt + 1, forKey: BeaconErrors.kTotalCount)
    } else {
      LocalStorage.setObject(1, forKey: BeaconErrors.kTotalCount)
    }
  }
  
  static func addRetryCount() {
    if let cnt = LocalStorage.objectForKey(BeaconErrors.kRetryCount) as? Int {
      LocalStorage.setObject(cnt + 1, forKey: BeaconErrors.kRetryCount)
    } else {
      LocalStorage.setObject(1, forKey: BeaconErrors.kRetryCount)
    }
  }
  
  static func getTotalCount() -> Int {
    if let cnt = LocalStorage.objectForKey(BeaconErrors.kTotalCount) as? Int {
      return cnt
    }
    return 0
  }
  
  static func getRetryCount() -> Int {
    if let cnt = LocalStorage.objectForKey(BeaconErrors.kRetryCount) as? Int {
      return cnt
    }
    return 0
  }
  
  static func clearTotalCount() {
    LocalStorage.setObject(0, forKey: BeaconErrors.kTotalCount)
  }
  
  static func clearRetryCount() {
    LocalStorage.setObject(0, forKey: BeaconErrors.kRetryCount)
  }
  
  //上传BLE日志到server
  static func uploadLogs() {
    //don't upload logs to the server if last upload time is within 24 hours
    if let lastUploadTime = BeaconErrors.getLastUploadTime() where fabs(lastUploadTime.timeIntervalSinceNow) < 24 * 3600 {
      return
    }
    
    if let allErrors = BeaconErrors.allWithOrder(["timestamp":"ASC"])  as? [BeaconErrors] where allErrors.count > 0 {
      var logs : String = ""
      for error in allErrors {
        //print("\(e.timestamp)")
        guard let ts = error.timestamp?.timeIntervalSince1970 else {
          error.remove()
          continue
        }
        
        logs = logs + "[\(ts)]:[\(AccountManager.sharedInstance().phone)]:[iOS]:[Apple]:[no IMEI]:[\(error.error)]\n"
        //print("remove:\(e.timestamp)")
        error.remove()
      }
      if logs.isEmpty {
        return
      }
      logs = "[RetryCount:\(getRetryCount())]:[TotalCount:\(getTotalCount())]\n" + logs
      guard let data = logs.dataUsingEncoding(NSUTF8StringEncoding) else { return }
      BeaconErrors.setLastUploadTime(NSDate())
      //send all logs to server here
      HttpService.sharedInstance.uploadLogs(fileName(), file: data, completionHandler: { (json, error) -> Void in
          BeaconErrors.saveAllChanges()
          BeaconErrors.clearRetryCount()
          BeaconErrors.clearTotalCount()
      })
    }
  }
  
}
