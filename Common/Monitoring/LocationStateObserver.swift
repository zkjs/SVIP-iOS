//
//  LocationStateObserver.swift
//  SVIP
//
//  Created by Qin Yejun on 3/16/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import CoreLocation

class LocationStateObserver:NSObject {
  static let sharedInstance = LocationStateObserver()
  private let locationManager: CLLocationManager
  
  var status: CLAuthorizationStatus {
    return CLLocationManager.authorizationStatus()
  }
  
  private override init() {
    locationManager = CLLocationManager()
    super.init()
    locationManager.delegate = self
  }
  
  func start() {
    if CLLocationManager.authorizationStatus() == .Denied {
      let alert = UIAlertView(title: "无法获得位置", message: "仅在您有预约时，在您抵达之前提醒服务人员准备好您的服务；您可以在个人设置中开启或关闭", delegate: nil, cancelButtonTitle: "确定")
      alert.show()
      return
    } else if CLLocationManager.authorizationStatus() == .Restricted {
      let alert = UIAlertView(title: "无法获得位置", message: "仅在您有预约时，在您抵达之前提醒服务人员准备好您的服务；您可以在个人设置中开启或关闭", delegate: nil, cancelButtonTitle: "确定")
      alert.show()
      return
    }

    if CLLocationManager.authorizationStatus() == .NotDetermined {
      locationManager.requestAlwaysAuthorization()
      return
    }
    
    //开始监听beacon
    if StorageManager.sharedInstance().settingMonitoring() {
      BeaconMonitor.sharedInstance.startMonitoring()
      LocationMonitor.sharedInstance.startUpdatingLocation()
    }
  }
}

extension LocationStateObserver: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    switch status {
    case .Denied,.Restricted:
      let alert = UIAlertView(title: "无法获得位置", message: "我们将为您提供免登记入住手续,该项服务需要使用定位功能,需要您前往设置中心打开定位服务", delegate: nil, cancelButtonTitle: "确定")
      alert.show()
    case .AuthorizedAlways, .AuthorizedWhenInUse:
      //开始监听beacon
      if StorageManager.sharedInstance().settingMonitoring() {
        BeaconMonitor.sharedInstance.startMonitoring()
        LocationMonitor.sharedInstance.startUpdatingLocation()
      }
    default:
      break
    }

  }
  
  
  func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
 
  }
}