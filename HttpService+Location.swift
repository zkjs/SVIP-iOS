//
//  HttpService+Location.swift
//  SVIP
//
//  Created by Qin Yejun on 3/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension HttpService {
  
  //// PYXIS 位置服务API : Beacon 位置信息 :
  func sendBeaconChanges(uuid:String, major:String, minor:String, sensorID: String = "", timestamp:Int, completionHandler:HttpCompletionHandler?){
    let urlString = baseLocationURL + ResourcePath.Beacon.description
    guard  let token = TokenPayload.sharedInstance.token else {return}
    print(token)
    let dict = ["locid":major,"major":major,"minor":minor,"uuid":uuid,"sensorid":"","timestamp":"\(timestamp)"]
    print(dict)
    
    requestTimeoutAPI(.PUT, urlString: urlString, parameters: dict,tokenRequired: true) {[unowned self] (json, error) -> Void in
      completionHandler?(json, error);
      if let error = error {
        print("beacon fail:\(error)")
        //还未超过最大重发次数
        if self.beaconRetryCount < self.maxBeaconRetryCount {
          self.beaconRetryCount += 1
          self.sendBeaconChanges(uuid, major: major, minor: minor, sensorID: sensorID, timestamp: timestamp, completionHandler: completionHandler)
          HttpErrorRecordingService.sharedInstance.recordBeaconError(uuid, major: major, minor: minor, error: error)
        } else {
          self.beaconRetryCount = 0
        }
      } else {
        print("beacon success")
      }
    }
  }
  
  //// PYXIS 位置服务API : GPS 位置信息 :
  func sendGpsChanges(latitude:CLLocationDegrees, longitude:CLLocationDegrees, altitude:CLLocationDistance,  timestamp:Int, completionHandler:HttpCompletionHandler?){
    let urlString = baseLocationURL + ResourcePath.GPS.description
    
    let dict = ["latitude":latitude.format("0.6"),"longitude":longitude.format("0.6"),"altitude":altitude.format("0.6"),"timestamp":"\(timestamp)"]
    print(dict)
    
    requestTimeoutAPI(.PUT, urlString: urlString, parameters: dict,tokenRequired: true) { (json, error) -> Void in
      completionHandler?(json, error);
      if let error = error {
        print("gps upload fail:\(error)")
      } else {
        print("gps upload success")
      }
    }
    
  }
}