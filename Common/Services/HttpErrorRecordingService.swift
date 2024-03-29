//
//  HttpErrorRecordingService.swift
//  SVIP
//
//  Created by Qin Yejun on 3/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReachabilitySwift

class HttpErrorRecordingService {
  static let sharedInstance = HttpErrorRecordingService()
  private init(){}
  
  func recordBeaconError(uuid:String, major:String, minor:String, error:NSError) {
    guard let err = BeaconErrors.create() as? BeaconErrors else {
      return
    }
    err.uuid = uuid
    err.major = major
    err.minor = minor
    err.error = "\(error)"
    err.timestamp = NSDate()
    err.connectionType = getConnectType()
    err.save()
  }
  
  func getConnectType () -> String {
    var type = ""
    do {
      let reachability: Reachability = try Reachability.reachabilityForInternetConnection()
      if reachability.isReachableViaWiFi() {
        type = "wifi"
      } else if reachability.isReachableViaWWAN() {
        type = "wwan"
      } else {
        type = "no network"
      }
      return type
    } catch {
      return "no network"
    }
  }
}