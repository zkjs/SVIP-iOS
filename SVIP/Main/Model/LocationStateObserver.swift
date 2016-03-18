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
      let alert = UIAlertView(title: "无法获得位置", message: "我们将为您提供免登记入住手续,该项服务需要使用定位功能,需要您前往设置中心打开定位服务", delegate: nil, cancelButtonTitle: "确定")
      alert.show()
      return
    } else if CLLocationManager.authorizationStatus() == .Restricted {
      let alert = UIAlertView(title: "无法获得位置", message: "我们将为您提供免登记入住手续,该项服务需要使用定位功能,需要您前往设置中心打开定位服务", delegate: nil, cancelButtonTitle: "确定")
      alert.show()
      return
    }

    if CLLocationManager.authorizationStatus() == .NotDetermined {
      locationManager.requestAlwaysAuthorization()
      return
    }
    
    //开始监听beacon
    BeaconMonitor.sharedInstance.startMonitoring()
  }
}

extension LocationStateObserver: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status != CLAuthorizationStatus.AuthorizedAlways {
      let alert = UIAlertView(title: "无法获得位置", message: "我们将为您提供免登记入住手续,该项服务需要使用定位功能,需要您前往设置中心打开定位服务", delegate: nil, cancelButtonTitle: "确定")
      alert.show()
    } else {
      //开始监听beacon
      BeaconMonitor.sharedInstance.startMonitoring()
    }
  }
  
  
  func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
 
  }
}