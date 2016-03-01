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

let BEACON_UUID = "FDA50693-A4E2-4FB1-AFCF-C6EB07647835"
let BEACON_IDENTIFIER = "com.zkjinshi.svpi"
let BEACON_INERVAL_MIN = 1 //BEACON 重复发起API请求最小时间间隔,单位：分钟

class BeaconMonitor:NSObject {
  private static let sharedInstance = BeaconMonitor()
  let locationManager = CLLocationManager()
  let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: BEACON_UUID)!, identifier: BEACON_IDENTIFIER)
  
  class var sharedMonitor : BeaconMonitor {
    return sharedInstance
  }
  
  func startMonitoring () {
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    startMonitoringRegion()
  }
  
  private func startMonitoringRegion() {
    //beaconRegion.notifyEntryStateOnDisplay = true
    beaconRegion.notifyOnEntry = true
    beaconRegion.notifyOnExit = true
    locationManager.startMonitoringForRegion(beaconRegion)
    locationManager.startRangingBeaconsInRegion(beaconRegion)
  }
}

extension BeaconMonitor : CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if let region = region as? CLBeaconRegion {
      print("enter beaconRegion:\(region)")
      self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
      //didEnterBeaconRegion(region as! CLBeaconRegion)
      
      /////////////////////////////for test, 数据测试代码
      /*let url = "http://api.lvzlv.com/index/beacon?source=svip&type=enter&major=\(region.major)&minor=\(region.minor)&uuid=\(region.proximityUUID.UUIDString)"
      request(.GET, url).response{ (request, ResponseSerializer, data, error) -> Void in
        if let error = error {
          print(error)
        } else {
          print("success")
        }
      }*/
      /////////////////////////////end of test
    }
  }
  
  func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
    //测试POST
    if region.proximityUUID.UUIDString != BEACON_UUID {
      return
    }
    if beacons.count < 1 {
      return
    }
    
    for beacon  in beacons {
      print("range beacon:\(beacon)")
      didEnterBeaconRegion(beacon)
    }
  }
  
  
  func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
    if let region = region as? CLBeaconRegion {
      print("exit beaconRegion:\(region)")
      didExitBeaconRegion(region)
      
      /////////////////////////////for test, 数据测试代码
      /*let url = "http://api.lvzlv.com/index/beacon?source=svip&type=exit&major=\(region.major)&minor=\(region.minor)&uuid=\(region.proximityUUID.UUIDString)"
      request(.GET, url).response{ (request, ResponseSerializer, data, error) -> Void in
        if let error = error {
          print(error)
        } else {
          print("success")
        }
      }*/
      /////////////////////////////end of test
    }
  }
  
  private func didEnterBeaconRegion(beacon: CLBeacon!) {
    let currentTimeStamp = Int(NSDate().timeIntervalSince1970)
    //将当前beacon被扫描到的当前timestamp记录下来，如果上次扫描时间在xx分钟以内则不发送通知
    var cachedBeaconRegions = StorageManager.sharedInstance().cachedBeaconRegions() ?? [NSNumber: Int]()
    
    if let ts = cachedBeaconRegions[beacon.major] where ts > currentTimeStamp - BEACON_INERVAL_MIN * 60 {//xx分钟以内，不发送通知
      return
    }
    /*ZKJSLocationHTTPSessionManager.sharedInstance().regionalPositionChangeNoticeWithMajor(String(beacon.major), minior: String(beacon.minor), uuid:BEACON_UUID,sensorid:nil, timestamp:currentTimeStamp, success: { (task:NSURLSessionDataTask!, responObjects:AnyObject!) -> Void in
      print(responObjects)
      }, failure: { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        print(error)
    })*/
    
    cachedBeaconRegions[beacon.major] = currentTimeStamp
    StorageManager.sharedInstance().saveCachedBeaconRegions(cachedBeaconRegions)
    HttpService.sendBeaconChanges(BEACON_UUID, major: String(beacon.major), minor: String(beacon.minor), timestamp: currentTimeStamp) { (error) -> () in
      if let error = error {
        print("beacon fial")
      } else {
        print("beacon success")
      }
    }
    
    /////////////////////////////for test , 数据测试代码
    /*let url = "http://api.lvzlv.com/index/beacon?source=svip&type=record&major=\(beacon.major)&minor=\(beacon.minor)&uuid=\(beacon.proximityUUID.UUIDString)"
    request(.GET, url).response{ (request, ResponseSerializer, data, error) -> Void in
      if let error = error {
        print(error)
      } else {
        print("success")
      }
    }*/
    /////////////////////////////end of test
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