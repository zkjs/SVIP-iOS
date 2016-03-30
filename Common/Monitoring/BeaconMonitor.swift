//
//  BeaconMonitor.swift
//  SVIP
//  监控Beacon并将合适的数据发送到server
//
//  Created by Qin Yejun on 2/27/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import CoreLocation

let BEACON_UUIDS = ["FDA50693-A4E2-4FB1-AFCF-C6EB07647835","931DDF8E-10E4-11E5-9493-1697F925EC7B"]
let BEACON_IDENTIFIER = "com.zkjinshi.svip.beacon"
let BEACON_INERVAL_MIN = 1 //BEACON 重复发起API请求最小时间间隔,单位：分钟

class BeaconMonitor:NSObject {
  static let sharedInstance = BeaconMonitor()
  let locationManager = CLLocationManager()
  var beaconRegions = [CLBeaconRegion]()
  var beaconInfoCache = [String:BeaconInfo]()
  private override init () {
    for (idx,uuid) in BEACON_UUIDS.enumerate() {
      let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: uuid)!, identifier: "\(BEACON_IDENTIFIER).\(idx)")
      beaconRegions.append(beaconRegion)
    }
  }
  
  
  func startMonitoring () {
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    startMonitoringRegion()
  }
  
  private func startMonitoringRegion() {
    //beaconRegion.notifyEntryStateOnDisplay = true
    for beaconRegion in beaconRegions {
      beaconRegion.notifyOnEntry = true
      beaconRegion.notifyOnExit = true
      locationManager.startMonitoringForRegion(beaconRegion)
      locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
  }
}

extension BeaconMonitor : CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if let _ = region as? CLBeaconRegion {
      //      print("enter beaconRegion:\(region)")
      for beaconRegion in beaconRegions {
        self.locationManager.startRangingBeaconsInRegion(beaconRegion)
      }
      //didEnterBeaconRegion(region as! CLBeaconRegion)
    }
  }
  
  func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
    //测试POST
    if !BEACON_UUIDS.contains(region.proximityUUID.UUIDString.uppercaseString) {
      return
    }
    if beacons.count < 1 {
      return
    }
    
    for beacon  in beacons {
      //print("range beacon:\(beacon)")
      didRangeBeacons(beacon)
    }
  }
  
  
  func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
    if let region = region as? CLBeaconRegion {
      print("exit beaconRegion:\(region)")
      didExitBeaconRegion(region)
    }
  }
  
  private func didRangeBeacons(beacon: CLBeacon!) {
    let currentTimeStamp = Int(NSDate().timeIntervalSince1970)
    
    let key = "\(beacon.proximityUUID.UUIDString)-\(beacon.major)"
    
    print("\(key) : \(beacon.proximity.rawValue)")
    
    // beacon足够接近才发送到服务器
    /*if beacon.proximity == .Unknown {
     beaconInfoCache[key] = BeaconInfo(proximity: beacon.proximity)
     return
     }*/
    
    if let cachedInfo = beaconInfoCache[key] {
      //print("\(key) : \(beacon.proximity.rawValue) : update time")
      beaconInfoCache[key]?.timestamp = NSDate()
      
      // xx分钟以内，不发送通知
      if fabs(cachedInfo.timestamp.timeIntervalSinceNow) < Double(BEACON_INERVAL_MIN) * 30 {
        //return
      }
      
      // 用户位置变化太小则不发送
      if !cachedInfo.proximityChangedSince(beacon.proximity) {
        //return
      }
      // 已经发送过通知到server就返回
      return
    }
    
    print("\(key) : \(beacon.proximity.rawValue) : upload")
    beaconInfoCache[key] = BeaconInfo(proximity: beacon.proximity, uploadTime: NSDate())
    
    HttpService.sharedInstance.sendBeaconChanges(beacon.proximityUUID.UUIDString.lowercaseString, major: String(beacon.major), minor: String(beacon.minor), timestamp: currentTimeStamp, completionHandler:nil);
    
  }
  
  private func didExitBeaconRegion(region: CLBeaconRegion) {
    /*guard let major = region.major else {
    return
    }
    if var cachedBeaconInfo = StorageManager.sharedInstance().cachedBeaconInfo() {
    cachedBeaconInfo["\(region.proximityUUID.UUIDString)-\(major)"] = nil
    StorageManager.sharedInstance().saveCachedBeaconInfo(cachedBeaconInfo)
    }*/
    print("didExitBeaconRegion")
    for (key,info) in beaconInfoCache {
      let ts = fabs(info.timestamp.timeIntervalSinceNow)
      if ts > 5 {// check the beacon exit
        beaconInfoCache[key] = nil
        
        print("exit: \(key) : \(ts)")
        
      }
    }
  }
  
  
  private func appState() -> String {
    let app = UIApplication.sharedApplication()
    
    switch app.applicationState {
    case UIApplicationState.Active:
      return "Active"
    case .Background:
      return "Background"
    case .Inactive:
      return "Inactive"
    }
  }
}