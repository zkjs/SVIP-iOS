//
//  BeaconInfo.swift
//  SVIP
//
//  Created by Qin Yejun on 3/23/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconInfo: NSObject {
  var timestamp: NSDate
  var uploadTime: NSDate
  var proximity: CLProximity
  
  override init () {
    timestamp = NSDate()
    uploadTime = NSDate(timeIntervalSinceNow: Double(BEACON_INERVAL_MIN * -60))
    proximity = .Unknown
    super.init()
  }
  
  init(proximity:CLProximity) {
    timestamp = NSDate()
    uploadTime = NSDate(timeIntervalSinceNow: Double(BEACON_INERVAL_MIN * -60))
    self.proximity = proximity
    super.init()
  }
  
  init(proximity:CLProximity,uploadTime:NSDate) {
    timestamp = NSDate()
    self.uploadTime = uploadTime
    self.proximity = proximity
    super.init()
  }
  
  init(proximity:CLProximity,uploadTime:NSDate, timestamp:NSDate) {
    self.timestamp = timestamp
    self.uploadTime = uploadTime
    self.proximity = proximity
    super.init()
  }
  
  // MARK: NSCoding
  
  required convenience init?(coder decoder: NSCoder) {
    guard let timestamp = decoder.decodeObjectForKey("timestamp") as? NSDate,
      let uploadTime = decoder.decodeObjectForKey("uploadTime") as? NSDate,
      let proximity = decoder.decodeObjectForKey("proximity") as? Int
      else { return nil }
    
    self.init(proximity:CLProximity(rawValue: proximity) ?? CLProximity.Unknown, uploadTime:uploadTime, timestamp:timestamp)
  }
  
  func encodeWithCoder(coder: NSCoder) {
    coder.encodeObject(self.timestamp, forKey: "date")
    coder.encodeObject(self.uploadTime, forKey: "uploadTime")
    coder.encodeObject(self.proximity.rawValue, forKey: "proximity")
  }
  
  /*
  * 判断beacon和上次监听到的距离是否有大的变化
  */
  func proximityChangedSince(proximity:CLProximity) -> Bool {
    if self.proximity == proximity {
      return false
    }
    if self.proximity == .Near && proximity == .Immediate {
      return false
    }
    if self.proximity == .Immediate && proximity == .Near {
      return false
    }
    return true
  }
}
