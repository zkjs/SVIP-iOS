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
  var lastLocation : CLLocation?
  var lastTime: NSTimeInterval?
  var locationManager: CLLocationManager?
  
  func startMonitoringLocation () {
    print("######startMonitoringLocation")
    if let locationManager = locationManager {
      locationManager.stopUpdatingHeading()
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
  
  func startUpdatingLocation () {
    print("######startUpdatingLocation")
    if let locationManager = locationManager {
      locationManager.stopUpdatingLocation()
      locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager?.distanceFilter = 1000
    locationManager?.startUpdatingLocation()
  }
  
  func stopUpdatingLocation () {
    locationManager?.stopUpdatingHeading()
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
    print("\n*****location:\(location)")
    let ts = NSDate().timeIntervalSince1970
    if let lastLocation = lastLocation {
      let distance = lastLocation.distanceFromLocation(location)
      print("distance:[\(distance)]")
      print("current speed:[\(location.speed)]")
      if distance < 500 {
        self.lastLocation = location
        self.lastTime = ts
        print("distance less than 500m , don't send gps to server")
        return
      }
      if let lastTime = lastTime {
        if ts - lastTime < 0.01 {
          return
        }
        let speed = distance / (ts - lastTime)
        print("calculated speed : \(speed)")
        if speed >  50{
          print("return when too fast")
          return
        }
      }
    }
    lastLocation = location
    lastTime = ts
    
    HttpService.sendGpsChanges(location.coordinate.latitude, longitude: location.coordinate.longitude, altitude: location.altitude, timestamp: Int(NSDate().timeIntervalSince1970)) { (error) -> () in
      if let error = error {
        print("gps upload fail:\(error)")
      } else {
        print("gps upload success")
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
