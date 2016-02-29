//
//  LocationMonitor.swift
//  SVIP
//
//  Created by Qin Yejun on 2/29/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationMonitor:NSObject {
  static let sharedInstance = LocationMonitor()
  private override init() {}
  
  var afterResume = false
  
  var locationManager: CLLocationManager?
  
  func startMonitoringLocation () {
    if let locationManager = locationManager {
      locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager?.activityType = CLActivityType.OtherNavigation
    if #available(iOS 9.0, *) {
        locationManager?.allowsBackgroundLocationUpdates = true
    }
    
    locationManager?.requestAlwaysAuthorization()
    locationManager?.startMonitoringSignificantLocationChanges()
  }
  
  func restartMonitoringLocation () {
    locationManager?.stopMonitoringSignificantLocationChanges()
    
    locationManager?.requestAlwaysAuthorization()
    locationManager?.startMonitoringSignificantLocationChanges()
  }
  
  func stopMonitoringLocation () {
    locationManager?.stopMonitoringSignificantLocationChanges()
  }
}

extension LocationMonitor : CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if locations.count < 1 {
      return
    }
    //for location in locations {
    uploadLocation(locations.last!)
    //}
  }
  
  private func uploadLocation (location:CLLocation) {
    // TODO:  upload location to server
    
    /////////////////////////////for test
    /*let state = afterResume ? "killed" : appState()
    let url = "http://api.lvzlv.com/index/location?source=simulator&type=\(state)&lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)"
    request(.GET, url).response{ (request, ResponseSerializer, data, error) -> Void in
      if let error = error {
        print(error)
      } else {
        print("success")
      }
    }*/
    /////////////////////////////end of test
    
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
