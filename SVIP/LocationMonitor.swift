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
  
  enum LocationType {
    case Updating,Significiant,None
  }
  
  struct LastLocationInfo {
    var locationType = LocationType.None
    private var lastMortingLocation : CLLocation?
    private var lastMortingTime: NSTimeInterval?
    private var lastUpdatingLocation : CLLocation?
    private var lastUpdatingTime: NSTimeInterval?
    private var lastMortingUploadedTime: NSTimeInterval?
    private var lastUPdatingUploadedTime: NSTimeInterval?
    
    var lastLocation : CLLocation? {
      get {
        switch locationType {
        case .Updating:
          return lastUpdatingLocation
        case .Significiant:
          return lastMortingLocation
        default:
          return nil
        }
      }
      set(newValue) {
        switch locationType {
        case .Updating:
          lastUpdatingLocation = newValue
        case .Significiant:
          lastMortingLocation = newValue
        default:
          break
        }
      }
    }
    
    var lastTime : NSTimeInterval? {
      get {
        switch locationType {
        case .Updating:
          return lastUpdatingTime
        case .Significiant:
          return lastMortingTime
        default:
          return nil
        }
      }
      set(newValue) {
        switch locationType {
        case .Updating:
          lastUpdatingTime = newValue
        case .Significiant:
          lastMortingTime = newValue
        default:
          break
        }
      }
    }
    
    var lastUploadedTime : NSTimeInterval? {
      get {
        switch locationType {
        case .Updating:
          return lastUPdatingUploadedTime
        case .Significiant:
          return lastMortingUploadedTime
        default:
          return nil
        }
      }
      set(newValue) {
        switch locationType {
        case .Updating:
          lastUPdatingUploadedTime = newValue
        case .Significiant:
          lastMortingUploadedTime = newValue
        default:
          break
        }
      }
    }
  }
  
  var afterResume = false
  var locationManager: CLLocationManager?
  var lastLocationInfo = LastLocationInfo()
  
  
  func startMonitoringLocation () {
    print("######startMonitoringLocation")
    lastLocationInfo.locationType = .Significiant
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
    lastLocationInfo.locationType = .Updating
    print("######startUpdatingLocation")
    if let locationManager = locationManager {
      locationManager.stopUpdatingLocation()
      locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager?.distanceFilter = 200
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
    let howRecent = location.timestamp.timeIntervalSinceNow
    print("\n*****location since [\(howRecent)]:\(location)")
    
    // very important : if the cached location is too old, don't upload the location
    if abs(howRecent) > 40 {
      print("location too old.\(howRecent)")
      return
    }
    var paramForTest = "[howRecent:\(howRecent)]"
    let currentTime = NSDate().timeIntervalSince1970
    if let lastLocation = lastLocationInfo.lastLocation {
      let distance = lastLocation.distanceFromLocation(location)
      print("lastLocation:\(lastLocation)")
      print("distance:[\(distance)]")
      print("current speed:[\(location.speed)]")
      paramForTest = paramForTest + "[distance:\(distance)]"

      if let lastTime = lastLocationInfo.lastTime {
        self.lastLocationInfo.lastLocation = location
        self.lastLocationInfo.lastTime = currentTime
        //don't upload the location if too frequent
//        if let lastUploadedTime = self.lastLocationInfo.lastUploadedTime where fabs(currentTime - lastUploadedTime) < 10 {
//          print("too frequent:\(fabs(currentTime - lastUploadedTime))")
//          return
//        }
        
        let speed = distance / (currentTime - lastTime)
        print("calculated speed : [\(speed)] in [\(currentTime - lastTime)]")
        // not real speed
        if speed >  70{
          print("return when too fast")
          return
        }
        paramForTest = paramForTest + "[speed:\(speed)]"
        paramForTest = paramForTest + "[time:\(currentTime - lastTime)]"
      }
    } else {
      print("============first time")
      paramForTest = paramForTest + "[FirstTime]"
    }
    lastLocationInfo.lastLocation = location
    lastLocationInfo.lastTime = currentTime
    lastLocationInfo.lastUploadedTime = currentTime
    
    HttpService.sharedInstance.sendGpsChanges(location.coordinate.latitude, longitude: location.coordinate.longitude, altitude: location.altitude, timestamp: Int(NSDate().timeIntervalSince1970), completionHandler: nil)

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
