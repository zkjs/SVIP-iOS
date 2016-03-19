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

//let BEACON_UUID = "FDA50693-A4E2-4FB1-AFCF-C6EB07647835"
let BEACON_UUIDS = ["FDA50693-A4E2-4FB1-AFCF-C6EB07647835","931DDF8E-10E4-11E5-9493-1697F925EC7B"]
let BEACON_IDENTIFIER = "com.zkjinshi.svip.beacon"
let BEACON_INERVAL_MIN = 1 //BEACON 重复发起API请求最小时间间隔,单位：分钟

class BeaconMonitor:NSObject {
  static let sharedInstance = BeaconMonitor()
  let locationManager = CLLocationManager()
  var beaconRegions = [CLBeaconRegion]()
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
      didEnterBeaconRegion(beacon)
    }
  }
  
  
  func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
    if let region = region as? CLBeaconRegion {
      print("exit beaconRegion:\(region)")
      didExitBeaconRegion(region)
    }
  }
  
  private func didEnterBeaconRegion(beacon: CLBeacon!) {
    let currentTimeStamp = Int(NSDate().timeIntervalSince1970)
    //将当前beacon被扫描到的当前timestamp记录下来，如果上次扫描时间在xx分钟以内则不发送通知
    var cachedBeaconRegions = StorageManager.sharedInstance().cachedBeaconRegions() ?? [NSNumber: Int]()
    
    if let ts = cachedBeaconRegions[beacon.major] where ts > currentTimeStamp - BEACON_INERVAL_MIN * 60 {//xx分钟以内，不发送通知
      return
    }
    
    cachedBeaconRegions[beacon.major] = currentTimeStamp
    StorageManager.sharedInstance().saveCachedBeaconRegions(cachedBeaconRegions)
    HttpService.sharedInstance.sendBeaconChanges(beacon.proximityUUID.UUIDString.lowercaseString, major: String(beacon.major), minor: String(beacon.minor), timestamp: currentTimeStamp, completionHandler:nil);
  }
  
  private func didExitBeaconRegion(region: CLBeaconRegion) {
    guard let major = region.major else {
      return
    }
    if var cachedBeaconRegions = StorageManager.sharedInstance().cachedBeaconRegions() {
      cachedBeaconRegions[major] = 0
      StorageManager.sharedInstance().saveCachedBeaconRegions(cachedBeaconRegions)
    }
  }
}