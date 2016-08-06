//
//  HttpService+Location.swift
//  SVIP
//
//  Created by Qin Yejun on 3/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

extension HttpService {
  
  //// PYXIS 位置服务API : Beacon 位置信息 :
  func sendBeaconChanges(uuid:String, major:String, minor:String, sensorID: String = "", timestamp:Int64, completionHandler:HttpCompletionHandler?){
    let urlString = ResourcePath.Beacon.description.fullUrl
    guard  let token = TokenPayload.sharedInstance.token else {return}
    print(token)
    let dict = ["locid":major,"major":major,"minor":minor,"uuid":uuid,"sensorid":"","timestamp":"\(timestamp)"]
    print(dict)
    
    requestTimeoutAPI(.PUT, urlString: urlString, parameters: dict,tokenRequired: true) {[unowned self] (json, error) -> Void in
      completionHandler?(json, error);
      //增加总请求数
      BeaconErrors.addTotalCount()
      if let error = error {
        print("beacon fail:\(error)")
        //还未超过最大重发次数
        if self.beaconRetryCount < self.maxBeaconRetryCount {
          self.beaconRetryCount += 1
          //增加重复请求数
          BeaconErrors.addRetryCount()
          // 延迟x秒后重新发送请求
          delay(seconds: Double(self.beaconRetryDelay), completion: {
            self.sendBeaconChanges(uuid, major: major, minor: minor, sensorID: sensorID, timestamp: timestamp, completionHandler: completionHandler)
          })
          // 记录错误日志
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
  func sendGpsChanges(latitude:CLLocationDegrees, longitude:CLLocationDegrees, altitude:CLLocationDistance,  timestamp:Int64, mac:String,ssid:String, completionHandler:HttpCompletionHandler?){
    let urlString = ResourcePath.GPS.description.fullUrl
    
    var dict = ["latitude":latitude.format("0.6"),"longitude":longitude.format("0.6"),"altitude":altitude.format("0.6"), "timestamp":"\(timestamp)"]
    if !mac.isEmpty {
      dict["mac"] = mac
    }
    if !ssid.isEmpty {
      dict["ssid"] = ssid
    }
    
    requestTimeoutAPI(.PUT, urlString: urlString, parameters: dict, tokenRequired: true) { (json, error) -> Void in
      completionHandler?(json, error);
      if let error = error {
        print("gps upload fail:\(error)")
      } else {
        print("gps upload success")
      }
    }
    
  }
  
  func uploadLogs(filename:String!,file:NSData, completionHandler:HttpCompletionHandler) {
    let urlString = ResourcePath.UploadLogs.description.fullUrl
    
    let parameters = ["filename":filename,"category":"ios"]

    guard  let token = TokenPayload.sharedInstance.token else {return}
    let headers = ["Content-Type":"multipart/form-data","Token":token]
    
    Alamofire.upload(.POST, urlString,headers: headers,multipartFormData: {
      multipartFormData in
      multipartFormData.appendBodyPart(data: file, name: "file", fileName: filename, mimeType: "application/octet-stream")
      for (key, value) in parameters {
        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
      }
      
      }, encodingCompletion: {
        encodingResult in
        switch encodingResult {
        case .Success(let upload, _, _):
          upload.response(completionHandler: { (request, response, data, error) -> Void in
            completionHandler(nil,error)
            if let error = error {
              print(error)
            } else {
              print(self.jsonFromData(data))
            }
            completionHandler(nil,error)
          })
          
        case .Failure(let encodingError):
          print(encodingError)
        }
    })
  }
  
  func uploadBeacons(beacons:[[String:String]], completionHandler:HttpCompletionHandler?) {
    if beacons.isEmpty { return }
    guard let token = TokenPayload.sharedInstance.token  where !token.isEmpty else {
      print("********* Token is required for [beacons] **********")
      return
    }
    
    //print(beacons)
    
    let urlString = ResourcePath.UploadBeacons.description.fullUrl
    
    let req = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    req.HTTPMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.setValue(token, forHTTPHeaderField: "Token")
    
    do {
      req.HTTPBody = try NSJSONSerialization.dataWithJSONObject(beacons, options: [])
      
      request(req).response { (req, res, data, error) in
        print("statusCode:\(res?.statusCode) for url:\(req?.URL?.absoluteString)")
        
        if let error = error {
          print("api request fail [res code:,\(res?.statusCode)]:\(error)")
          completionHandler?(nil,error)
        } else {
          print(self.jsonFromData(data))
          
          if let data = data {
            let json = JSON(data: data)
            if json["res"].int == 0 {
              completionHandler?(json,nil)
              print(json["resDesc"].string)
            } else {
              print("error with reason: \(json["resDesc"].string)")
            }
          }
        }
      }
    } catch _ {
      
    }
  }
  
  //// PYXIS 位置服务API : Beacon 位置信息 :
  func sendMultiBeacons(beacons:[BeaconInfo], completionHandler:HttpCompletionHandler?){
    let urlString = ResourcePath.MultiBeacon.description.fullUrl
    if beacons.isEmpty { return }
    guard let token = TokenPayload.sharedInstance.token  where !token.isEmpty else {
      print("********* Token is required for [multi beacons] **********")
      return
    }
    
    //print(beacons)
    let uploadBeacons = beacons.filter{ $0.beacon != nil }.map { bi -> [String:AnyObject] in
      let bc = bi.beacon!
      return ["major":"\(bc.major)", "minor":"\(bc.minor)", "uuid":"\(bc.proximityUUID.UUIDString)","rssis":bi.rssis]
    }
    
    let req = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    req.HTTPMethod = "PUT"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.setValue(token, forHTTPHeaderField: "Token")
    
    do {
      req.HTTPBody = try NSJSONSerialization.dataWithJSONObject(uploadBeacons, options: [])
      
      request(req).response { (req, res, data, error) in
        print("statusCode:\(res?.statusCode) for url:\(req?.URL?.absoluteString)")
        
        if let error = error {
          print("api request fail [res code:,\(res?.statusCode)]:\(error)")
          completionHandler?(nil,error)
        } else {
          print(self.jsonFromData(data))
          
          if let data = data {
            let json = JSON(data: data)
            if json["res"].int == 0 {
              completionHandler?(json,nil)
              print(json["resDesc"].string)
            } else {
              print("error with reason: \(json["resDesc"].string)")
            }
          }
        }
      }
    } catch _ {
      
    }
    
  }
  
  
  //// 自动支付beacon上报
  func sendAutoPayBeacons(beacons:[BeaconInfo], completionHandler:HttpCompletionHandler?){
    let urlString = ResourcePath.AutoPayBeacon.description.fullUrl
    if beacons.isEmpty { return }
    guard let token = TokenPayload.sharedInstance.token  where !token.isEmpty else {
      print("********* Token is required for [multi beacons] **********")
      return
    }
    
    //print(beacons)
    let uploadBeacons = beacons.filter{ $0.beacon != nil }.map { bi -> [String:AnyObject] in
      let bc = bi.beacon!
      return ["major":"\(bc.major)", "minor":"\(bc.minor)", "uuid":"\(bc.proximityUUID.UUIDString)","rssis":bi.rssis]
    }
    print(uploadBeacons)
    let req = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    req.HTTPMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.setValue(token, forHTTPHeaderField: "Token")
    
    do {
      req.HTTPBody = try NSJSONSerialization.dataWithJSONObject(uploadBeacons, options: [])
      
      request(req).response { (req, res, data, error) in
        print("statusCode:\(res?.statusCode) for url:\(req?.URL?.absoluteString)")
        
        if let error = error {
          print("[autopay] api request fail [res code:,\(res?.statusCode)]:\(error)")
          completionHandler?(nil,error)
        } else {
          print(self.jsonFromData(data))
          
          if let data = data {
            let json = JSON(data: data)
            if json["res"].int == 0 {
              completionHandler?(json,nil)
              print("[autopay] success")
              print(json["resDesc"].string)
            } else {
              print("[autopay] error with reason: \(json["resDesc"].string)")
            }
          }
        }
      }
    } catch _ {
      
    }
    
  }
}