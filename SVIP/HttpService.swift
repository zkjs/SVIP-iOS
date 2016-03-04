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
//  private static let baseCodeURL = "http://192.168.199.112:8082" //局域网测试IP
  
  private enum ResourcePath: CustomStringConvertible {
    case ApiURL(path:String)              // demo
    case Beacon                           // PYXIS 位置服务API : Beacon 位置信息 : 
    case GPS                              // PYXIS 位置服务API : GPS 位置信息 :
    case CodeLogin                             // PAVO 认证服务API : 验证码 : HEADER不需要Token
    case CodeRegister             //注册获取验证码
    case register                         //注册获取token
    case Login                            // PAVO 认证服务API : 使用手机验证码创建Token : HEADER不需要Token
    case Token                            // PAVO 认证服务API : Token管理 :
    case DeleteToken
    case updata                      //更新资料
    
    var description: String {
      switch self {
      case .ApiURL(let path): return "/api/\(path)"
      case .Beacon: return "/lbs/v1/loc/beacon"
      case .GPS: return "/lbs/v1/loc/gps"
      case .CodeLogin : return "/sso/vcode/v1/si/login"
      case .CodeRegister : return "/sso/vcode/v1/si/register"
      case .Login: return "/sso/token/v1/phone/si"
      case .Token: return "/sso/token/v1"
      case.DeleteToken: return "/sso/token/v1"
      case.updata: return "/res/v1/register/update/si"
      case.register: return "/res/v1/register/si"
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
    requestAPI(.PUT, urlString: urlString, parameters: parameters) { (json, err) -> Void in
      if let err = err {
        completionHandler(json, err)
      } else {
        completionHandler(json, nil)
      }
    }
  }
  

  
  static func delete(urlString: String, parameters: [String : AnyObject]? , completionHandler: ((JSON?, NSError?) -> Void)) {
    requestAPI(.DELETE, urlString: urlString, parameters: parameters) { (json, err) -> Void in
      if let err = err {
        completionHandler(json, err)
      } else {
        completionHandler(json, nil)
      }
    }
  }
  
  static func post(urlString: String, parameters: [String : AnyObject]? , completionHandler: ((JSON?, NSError?) -> Void)) {
    requestAPI(.POST, urlString: urlString, parameters: parameters) { (json, err) -> Void in
      if let err = err {
        completionHandler(json, err)
      } else {
        completionHandler(json, nil)
      }
    }
  }
  
  
  
  
  
  static func get(urlString: String, parameters: [String : AnyObject]? , completionHandler: ((JSON?, NSError?) -> Void)) {
    requestAPI(.GET, urlString: urlString, parameters: parameters) { (json, err) -> Void in
      if let err = err {
        completionHandler(json, err)
      } else {
        completionHandler(json, nil)
      }
    }
  }
  
  
  //HTTP REQUEST
  static func requestAPI(method: Method, urlString: String, parameters: [String : AnyObject]? ,tokenRequired:Bool = true, completionHandler: ((JSON?, NSError?) -> Void)) {
    
    var headers = ["Content-Type":"application/json"]
    if let token = TokenPayload.sharedInstance.token {
      headers["Token"] = token
    } else {
      if tokenRequired {
        return
      }
    }
    
    print(urlString)
    print(parameters)
    
    request(method, urlString, parameters: parameters, encoding: .JSON, headers: headers).response { (req, res, data, error) -> Void in
      if let error = error {
        print("api request fail:\(error)")
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
              userInfo: ["res":"\(json["res"].int)","resDesc":json["resDesc"].string ?? ""])
            completionHandler(json,e)
            print("error with reason: \(json["resDesc"].string)")
            if let key = json["res"].int {
              ZKJSTool.showMsg("\(key)")
            }
          }
        } else {
          let e = NSError(domain: NSBundle.mainBundle().bundleIdentifier ?? "com.zkjinshi.svip",
            code: -2,
            userInfo: ["res":"-2","resDesc": "no data from server"])
          completionHandler(nil,e)
          print("error with reason: \(e)")
        }
      }
    }
  }
  
  //// PYXIS 位置服务API : Beacon 位置信息 :
  static func sendBeaconChanges(uuid:String, major:String, minor:String, sensorID: String = "", timestamp:Int, completionHandler:(NSError?) -> ()){
    let urlString = baseLocationURL + ResourcePath.Beacon.description
    guard  let token = TokenPayload.sharedInstance.token else {return}
    print(token)
    let dict = ["locid":major,"major":major,"minor":minor,"uuid":uuid,"sensorid":"","timestamp":"\(timestamp)"]
    print(dict)
    put(urlString, parameters: dict) { (data, error) -> Void in
      completionHandler(error);
    }
    
  }
  
  //// PYXIS 位置服务API : GPS 位置信息 :
  static func sendGpsChanges(latitude:CLLocationDegrees, longitude:CLLocationDegrees, altitude:CLLocationDistance,  timestamp:Int, completionHandler:(NSError?) -> ()){
    let urlString = baseLocationURL + ResourcePath.GPS.description
    
    let dict = ["latitude":latitude.format("0.6"),"longitude":longitude.format("0.6"),"altitude":altitude.format("0.6"),"timestamp":"\(timestamp)"]
    print(dict)
    put(urlString, parameters: dict) { (data, error) -> Void in
      completionHandler(error)
    }
    
  }
  
  //// PAVO 认证服务API : 验证码 : HEADER不需要Token(登录)
  static func requestSmsCodeWithPhoneNumber(phone:String,completionHandler:(JSON?, NSError?) -> ()){
    let urlString = baseCodeURL + ResourcePath.CodeLogin.description
    let key = "X2VOV0+W7szslb+@kd7d44Im&JUAWO0y"
    let data: NSData = phone.dataUsingEncoding(NSUTF8StringEncoding)!
    let encryptedData = data.AES256EncryptWithKey(key).base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    let dict = ["phone":"\(encryptedData)"]
    post(urlString, parameters: dict) { (json, error) -> Void in
      completionHandler(json,error)
    }
  
    }
  
  
  ////注册使用验证码获取token
  static func registerWithPhoneNumber(phone:String,code:String,completionHandler:(JSON?, NSError?) -> ()) {
    let urlString = baseCodeURL + ResourcePath.register.description
    let dict = ["phone":"\(phone)","code":code]
    post(urlString, parameters: dict) { (json, error) -> Void in
      completionHandler(json,error)
      if let json = json {
        guard let token = json["token"].string else {
          print("no token")
          return
        }
        let tokenPayload = TokenPayload.sharedInstance
        tokenPayload.saveTokenPayload(token)

      }
    }

  }

  
  //// PAVO 认证服务API : 使用手机验证码创建Token : HEADER不需要Token
  static func loginWithCode(code:String,phone:String,completionHandler:(JSON?,NSError?) -> ()) {
    let urlString = baseCodeURL + ResourcePath.Login.description
    
    let dict = ["phone":"\(phone)","code":"\(code)"]
    post(urlString, parameters: dict) { (json, error) -> Void in
      if let json = json {
        guard let token = json["token"].string else {
          print("no token")
          return
        }
        let tokenPayload = TokenPayload.sharedInstance
        tokenPayload.saveTokenPayload(token)
        
        //登录成功后订阅云巴推送
        if let userID = tokenPayload.userID {
          print("userID:\(userID)")
          YunBaService.setAlias(userID, resultBlock: { (succ, err) -> Void in
            if succ {
              print("yunba setAlias success");
            } else {
              print("yunba setAlias fail");
            }
          })
        }
      } else {
        
      }

      completionHandler(json, error)
    }

  }
  
  //// PAVO 认证服务API : Token管理 :
  static func managerToken(completionHandler:(JSON?,NSError?) -> ()) {
    let urlString = baseCodeURL + ResourcePath.Token.description

    put(urlString, parameters: nil) { (json, error) -> Void in
      completionHandler(json, error)
      if let json = json {
        guard let token = json["token"].string else {
          print("no token")
          return
        }
        print("success")
        print(token)
        let tokenPayload = TokenPayload.sharedInstance
        tokenPayload.saveTokenPayload(token)
        
    }
    }
  }
  
   //// PAVO 认证服务API : Token管理 :
  static func deleteToken(completionHandler:(JSON?,NSError?) -> ()) {
    let urlString = baseCodeURL + ResourcePath.Token.description
    guard   let token = TokenPayload.sharedInstance.token else {return}
    let dic = ["token":token]
    put(urlString, parameters: dic) { (json, error) -> Void in
      completionHandler(json, error)
        }
  }
  
  //// PAVO 认证服务API : 验证码 : HEADER不需要Token(注册获取验证码)
  static func registerSmsCodeWithPhoneNumber(phone:String,completionHandler:(JSON?, NSError?) -> ()){
    let urlString = baseCodeURL + ResourcePath.CodeLogin.description
    let key = "X2VOV0+W7szslb+@kd7d44Im&JUAWO0y"
    let data: NSData = phone.dataUsingEncoding(NSUTF8StringEncoding)!
    let encryptedData = data.AES256EncryptWithKey(key).base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    let dict = ["phone":"\(encryptedData)"]
    post(urlString, parameters: dict) { (json, error) -> Void in
      completionHandler(json,error)
    }
    
  }

  
  //////注册流程 完善资料
  static func updateUserInfoWithUsername(realname:String,sex:String,image:UIImage,completionHandler:(JSON?,NSError?) -> ()) {
    let parameters = [
      "realname": realname,
      "sex": sex]
    var headers = ["Content-Type":"application/json"]
    if let token = TokenPayload.sharedInstance.token {
      headers["Token"] = token
    } else {
      
    }
    let urlString = baseCodeURL + ResourcePath.updata.description
    upload(.POST, urlString,headers: headers,multipartFormData: {
      multipartFormData in
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
          multipartFormData.appendBodyPart(data: imageData, name: "file", fileName: "file.png", mimeType: "image/png")
        }
      
      for (key, value) in parameters {
        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
      }
      
      }, encodingCompletion: {
        encodingResult in
        switch encodingResult {
        case .Success(let upload, _, _):
          upload.response(completionHandler: { (request, response, data, error) -> Void in
            if let error = error {
              print(error)
            } else {
              completionHandler(nil,error)
            }
          })

        case .Failure(let encodingError):
          print(encodingError)
        }
    })

  }
}