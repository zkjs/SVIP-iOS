//
//  HttpService.swift
//  SVIP
//
// Server API 数据请求类
//
//  Created by Qin Yejun on 2/29/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

struct HttpService {
  private static let ImageURL = "http://svip02.oss-cn-shenzhen.aliyuncs.com"  // 图片服务器
  
  // 测试
  private static let baseURL = "http://tst.zkjinshi.com/"  // PHP服务器
  private static let baseURLJava = "http://test.zkjinshi.com/japi/"  // Java服务器
  private static let EaseMobAppKey = "zkjs#svip"  // 环信
  
  // 预上线
  /*
  private static let baseURL = "http://rap.zkjinshi.com/"  // PHP服务器
  private static let baseURLJava = "http://p.zkjinshi.com/japi/"  // Java服务器
  private static let EaseMobAppKey = "zkjs#sid"  // 环信
  */
  
  // 正式
  /*
  private static let baseURL = "http://api.zkjinshi.com/"  // PHP服务器
  private static let baseURLJava = "http://mmm.zkjinshi.com/"  // Java服务器
  private static let EaseMobAppKey = "zkjs#prosvip"  // 环信
  */
  
  //位置
  private static let baseLocationURL = "http://120.25.80.143:8082" //推送/更新室内位置
  private static let baseCodeURL = "http://120.25.80.143:8080" //获取code
  
  private enum ResourcePath: CustomStringConvertible {
    case ApiURL(path:String)
    case Beacon
    case GPS
    case CODE
    case  Login
    case TOKEN
    
    var description: String {
      switch self {
      case .ApiURL(let path): return "/api/\(path)"
      case .Beacon: return "/lbs/v1/loc/beacon"
      case .GPS: return "/lbs/v1/loc/gps"
      case.CODE : return "/sso/vcode/v1/si"
      case.Login: return "/sso/token/v1/phone/si"
      case.TOKEN: return "/sso/token/v1"
      }
    }
  }
  
  static func jsonFromData(jsonData:NSData?) -> NSDictionary?  {
    guard let jsonData = jsonData else {
      return nil
    }
    guard let parsed = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary else {
      return nil
    }
    return parsed
  }
  
  static func put(urlString: String, parameters: [String : AnyObject]? , completionHandler: ((JSON?, NSError?) -> Void)) {
    ///////////////////////////////// token for test
    let token = "eyJhbGciOiJSUzUxMiJ9.eyJzdWIiOiJjXzU2YTZlN2I1NjM0OGMiLCJ0eXBlIjozLCJleHBpcmUiOjE0NTY4MjQxNDMxNjEsInNob3BpZCI6Ijg4ODgiLCJyb2xlcyI6W10sImZlYXR1cmUiOltdfQ.KSCmIWoc8Vuj7A03wFZhukgTlnq38WVLDgEbU7TO51pNTwuQ3Q36RSqMh4DOxlftkp7WLfvsn63KChZZGGZryoGEKZ8nOdVP4YCS7cJMN8WZKYt_3gdmt3l9eGAHa7d-EhqOpY-Qk0iZlHA_x134N-z9GFpE5sZJfaGllQ7W7pQ"
    
    request(.PUT, urlString, parameters: parameters, encoding: .JSON, headers: ["Content-Type":"application/json","Token":token]).response { (req, res, data, error) -> Void in
      if let error = error {
        print("api request[put] fail:\(error)")
        completionHandler(nil,error)
      } else {
        print(jsonFromData(data))
        
        if let data = data {
          let json = JSON(data: data)
          if json["res"].int == 0 {
            completionHandler(json,nil)
            print(json["resDesc"].string)
          } else {
            let e = NSError(domain: NSBundle.mainBundle().bundleIdentifier ?? "com.zkjinshi.svip",
              code: -1,
              userInfo: ["msg":"no data","res":"\(json["res"].int)","resDesc":json["resDesc"].string ?? ""])
            completionHandler(json,e)
            print("error with reason: \(json["resDesc"].string)")
          }
        } else {
          completionHandler(nil,error)
        }
      }
    }
  }
  static func post(urlString: String, parameters: [String : AnyObject]? , completionHandler: ((JSON?, NSError?) -> Void)) {
    ///////////////////////////////// token for test
    let token = "eyJhbGciOiJSUzUxMiJ9.eyJzdWIiOiJjXzU2YTZlN2I1NjM0OGMiLCJ0eXBlIjozLCJleHBpcmUiOjE0NTY4MjQxNDMxNjEsInNob3BpZCI6Ijg4ODgiLCJyb2xlcyI6W10sImZlYXR1cmUiOltdfQ.KSCmIWoc8Vuj7A03wFZhukgTlnq38WVLDgEbU7TO51pNTwuQ3Q36RSqMh4DOxlftkp7WLfvsn63KChZZGGZryoGEKZ8nOdVP4YCS7cJMN8WZKYt_3gdmt3l9eGAHa7d-EhqOpY-Qk0iZlHA_x134N-z9GFpE5sZJfaGllQ7W7pQ"
    
    request(.POST, urlString, parameters: parameters, encoding: .JSON, headers: ["Content-Type":"application/json","Token":token]).response { (req, res, data, error) -> Void in
      if let error = error {
        print("api request[put] fail:\(error)")
        completionHandler(nil,error)
      } else {
        print(jsonFromData(data))
        
        if let data = data {
          let json = JSON(data: data)
          if json["res"].int == 0 {
            completionHandler(json,nil)
            print(json["resDesc"].string)
          } else {
            let e = NSError(domain: NSBundle.mainBundle().bundleIdentifier!,
              code: -1,
              userInfo: ["msg":"no data","res":"\(json["res"].int)","resDesc":json["resDesc"].string ?? ""])
            completionHandler(json,e)
            print("error with reason: \(json["resDesc"].string)")
          }
        } else {
          completionHandler(nil,error)
        }
      }
    }
  }
  
  static func sendBeaconChanges(uuid:String, major:String, minor:String, sensorID: String = "", timestamp:Int, completionHandler:(NSError?) -> ()){
    let urlString = baseLocationURL + ResourcePath.Beacon.description
    
    let dict = ["locid":major,"major":major,"minor":minor,"uuid":uuid,"sensorid":"","timestamp":"\(timestamp)"]
    print(dict)
    put(urlString, parameters: dict) { (data, error) -> Void in
      completionHandler(error);
    }
    
  }
  
  static func sendGpsChanges(latitude:CLLocationDegrees, longitude:CLLocationDegrees, altitude:CLLocationDistance,  timestamp:Int, completionHandler:(NSError?) -> ()){
    let urlString = baseLocationURL + ResourcePath.GPS.description
    
    let dict = ["latitude":latitude.format("0.6"),"longitude":longitude.format("0.6"),"altitude":altitude.format("0.6"),"timestamp":"\(timestamp)"]
    print(dict)
    put(urlString, parameters: dict) { (data, error) -> Void in
      completionHandler(error)
    }
    
  }
  
  static func requestSmsCodeWithPhoneNumber(phone:String,completionHandler:(JSON?, NSError?) -> ()){
    let urlString = baseCodeURL + ResourcePath.CODE.description
    let key = "X2VOV0+W7szslb+@kd7d44Im&JUAWO0y"
    let data: NSData = phone.dataUsingEncoding(NSUTF8StringEncoding)!
    let encryptedData = data.AES256EncryptWithKey(key).base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    let dict = ["phone":"\(encryptedData)"]
    post(urlString, parameters: dict) { (json, error) -> Void in
      completionHandler(json,error)
    }
  
    }
  
  //pragma mark -使用手机验证码和手机获取Token
  static func loginWithCode(code:String,phone:String,completionHandler:(JSON?,NSError?) -> ()) {
    let urlString = baseCodeURL + ResourcePath.Login.description
    print(urlString)
    let dict = ["phone":"\(phone)","code":"\(code)"]
    post(urlString, parameters: dict) { (json, error) -> Void in
      if let json = json {
        let token = json["token"].string
        let array:NSArray = (token?.componentsSeparatedByString("."))!
        var tokenString :String
        if array.count > 2 {
          tokenString = array[1] as! String
        } else {
          return
        }
        let rem = tokenString.characters.count % 4
        var ending = ""
        if rem > 0 {
          let amount = 4 - rem
          ending = String(count: amount, repeatedValue: Character("="))
        }
        let base64 = tokenString.stringByReplacingOccurrencesOfString("-", withString: "+", options: NSStringCompareOptions(rawValue: 0), range: nil)
          .stringByReplacingOccurrencesOfString("_", withString: "/", options: NSStringCompareOptions(rawValue: 0), range: nil) + ending
        
        let decodedData = NSData(base64EncodedString:base64, options:NSDataBase64DecodingOptions(rawValue: 0))
        let decodedString = NSString(data: decodedData!, encoding: NSUTF8StringEncoding) as! String
        AccountManager.sharedInstance().saveDeviceToken(decodedString)
      } else {
//        self.showHint("手机号或验证码不正确")
      }

      completionHandler(json, error)
    }

  }
  
  //pragma mark -TOKEN 管理
  
  static func managerToken(token:String,completionHandler:(JSON?,NSError?) -> ()) {
    let urlString = baseCodeURL + ResourcePath.TOKEN.description

    put(urlString, parameters: nil) { (json, error) -> Void in
      completionHandler(json, error)
    }
  }
  
  
}
