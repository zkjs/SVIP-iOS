//
//  Beacons.swift
//  SVIP
//
//  Beacon信息收集
//  http://p.zkjinshi.com/test/pyx/pyxis_api.html#beacon-位置信息-室内位置-post
//
//  Created by Qin Yejun on 4/19/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import CoreData


class Beacons: NSManagedObject {

  static let kLastUploadTime = "kBeaconsLastUploadTime"
  
  //最近一次上传Beacons时间
  static func getLastUploadTime() -> NSDate? {
    if let date = LocalStorage.objectForKey(kLastUploadTime) as? NSDate {
      return date
    }
    return nil
  }
  
  //设置最近上传Beacons时间
  static func setLastUploadTime(date:NSDate) {
    LocalStorage.setObject(date, forKey: kLastUploadTime)
  }
  
  // 记录beacon信息到本地
  static func recordBeaconInfo(beaconInfo:CLBeacon, location:CLLocation?) {
    guard let beacon = Beacons.create() as? Beacons else {
      return
    }
    beacon.uuid = beaconInfo.proximityUUID.UUIDString
    beacon.major = "\(beaconInfo.major)"
    beacon.minor = "\(beaconInfo.minor)"
    beacon.timestamp = NSDate()
    beacon.accuracy = beaconInfo.accuracy
    beacon.rssi = beaconInfo.rssi
    if let location = location {
      beacon.latitude = location.coordinate.latitude
      beacon.longitude = location.coordinate.longitude
      beacon.altitude = location.altitude
    }
    beacon.save()
  }
  

  //上传Beacons到server
  static func upload() {
    //don't upload beacons to the server if last upload time is within 30 minutes
    if let lastUploadTime = BeaconErrors.getLastUploadTime() where fabs(lastUploadTime.timeIntervalSinceNow) < 10 * 60 {
      return
    }
    
    guard let allBeacons = Beacons.allWithOrder(["timestamp":"ASC"]) as? [Beacons] else {
      return
    }
    
    // 每组上传数据至少10个beacon信息
    if allBeacons.count < 10 {
      return
    }
    
    var param = [[String:String]]()
    for beacon in allBeacons {
      //print("\(e.timestamp)")
      
      var p = [
        "major": beacon.major,
        "minor": beacon.minor,
        "uuid": beacon.uuid,
        "rssi": "\(beacon.rssi.intValue)",
        "accuracy": "\(beacon.accuracy.doubleValue)",
        "timestamp": "\(Int(beacon.timestamp.timeIntervalSince1970 * 1000))"
      ]
      if let lat = beacon.latitude?.doubleValue, let lng = beacon.longitude?.doubleValue,
        let alt = beacon.altitude?.doubleValue {
        p["latitude"] = "\(lat)"
        p["longitude"] = "\(lng)"
        p["altitude"] = "\(alt)"
      }
      
      param.append(p)
      beacon.remove()
    }
    
    Beacons.setLastUploadTime(NSDate())
    //send all beacons to server here
    HttpService.sharedInstance.uploadBeacons(param) { _ in
      Beacons.saveAllChanges()
    }
    
  }
  
}
