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

typealias HttpCompletionHandler = (JSON?, NSError?) -> Void

class HttpService {
  static let DefaultPageSize = 20
  //设置api请求超时时间
  static let TimeoutInterval:NSTimeInterval = 3
  static let sharedInstance = HttpService()
  //custom manager used for timeout version
  lazy var alamoFireManager : Manager = {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.timeoutIntervalForRequest = TimeoutInterval // seconds
    configuration.timeoutIntervalForResource = TimeoutInterval
    return Manager(configuration: configuration)
  }()
  private init() {}
  
  var beaconRetryCount = 0              //beacon 上传失败后重新请求当前次数
  let maxBeaconRetryCount = 3           //beacon 上传失败后重新请求最多次数
  
  
  enum ResourcePath: CustomStringConvertible {
    case ApiURL(path:String)            // demo
    case Beacon                         // PYXIS 位置服务API : Beacon 位置信息 :
    case GPS                            // PYXIS 位置服务API : GPS 位置信息 :
    case CodeLogin                      // PAVO 认证服务API : 验证码 : HEADER不需要Token
    case CodeRegister                   // 注册获取验证码
    case register                       // 注册获取token
    case Login                          // PAVO 认证服务API : 使用手机验证码创建Token : HEADER不需要Token
    case Token                          // PAVO 认证服务API : Token管理 :
    case DeleteToken
    case RegisterUpdata                 // 注册后更新资料
    case UserInfo                       // 获取用户资料
    case UserInfoUpdate                 // 更新用户资料
    case UploadLogs                     // 上传用户错误日志
    case ShopList                       // 商家列表
    case ShopDetail(id:String)          // 商家详情
    case ShopComments(shopid:String)    // 商家评论
    case querySaleFromCode              // 根据邀请码查询销售员
    case ActiveCode                     // 邀请码激活
    case HomePicture                    // 首页大图
    case HomePrivilegeIntro             // 首页大图
    case HomeRecom(city:String)         // 首页服务推荐
    case CheckVersion(version:String)   // 检查App版本
    
    var description: String {
      switch self {
      case .ApiURL(let path):           return "/api/\(path)"
      case .Beacon:                     return "/pyx/lbs/v1/loc/beacon"
      case .GPS:                        return "/pyx/lbs/v1/loc/gps"
      case .CodeLogin:                  return "/pav/sso/vcode/v1/si?source=login"
      case .CodeRegister:               return "/pav/sso/vcode/v1/si?source=register"
      case .Login:                      return "/pav/sso/token/v1/phone/si"
      case .Token:                      return "/pav/sso/token/v1"
      case .DeleteToken:                return "/pav/sso/token/v1"
      case .register:                   return "/pav/res/v1/register/si"
      case .RegisterUpdata:             return "/for/res/v1/register/update/si"
      case .UserInfo:                   return "/for/res/v1/query/user/all"
      case .UserInfoUpdate:             return "/for/res/v1/update/user"
      case .UploadLogs:                 return "/for/res/v1/upload/userlog"
      case .ShopList:                   return "/for/res/v1/shop"
      case .ShopDetail(let shopid):     return "/for/res/v1/shop/detail/\(shopid)"
      case .ShopComments(let shopid):   return "/for/res/v1/shop/comments/\(shopid)"
      case .querySaleFromCode:          return "/for/res/v1/salecode/saleuser"
      case .ActiveCode:                 return "/for/res/v1/salecode/active/salecode"
      case .HomePicture:                return "/for/res/v1/systempub/homepicture"
      case .HomePrivilegeIntro:         return "/for/res/v1/systempub/ssintroduction"
      case .HomeRecom(let city):        return "/for/res/v1/systempub/localservice/recommend/\(city)"
      case .CheckVersion(let version):  return "/for/res/v1/systempub/upgrade/newestversion/1/IOS/\(version)"
      }
    }
  }
  
  func jsonFromData(jsonData:NSData?) -> NSDictionary?  {
    guard let jsonData = jsonData else {
      return nil
    }
    guard let parsed = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary else {
      return nil
    }
    return parsed
  }
  
  func put(urlString: String, parameters: [String : AnyObject]? , tokenRequired:Bool=true, completionHandler: ((JSON?, NSError?) -> Void)) {
    requestAPI(.PUT, urlString: urlString, parameters: parameters,tokenRequired: tokenRequired) { (json, err) -> Void in
      if let err = err {
        completionHandler(json, err)
      } else {
        completionHandler(json, nil)
      }
    }
  }
  
  func delete(urlString: String, parameters: [String : AnyObject]? , tokenRequired:Bool=true, completionHandler: ((JSON?, NSError?) -> Void)) {
    requestAPI(.DELETE, urlString: urlString, parameters: parameters,tokenRequired: tokenRequired) { (json, err) -> Void in
      if let err = err {
        completionHandler(json, err)
      } else {
        completionHandler(json, nil)
      }
    }
  }
  
  func post(urlString: String, parameters: [String : AnyObject]? , tokenRequired:Bool=true, completionHandler: ((JSON?, NSError?) -> Void)) {
    requestAPI(.POST, urlString: urlString, parameters: parameters,tokenRequired: tokenRequired) { (json, err) -> Void in
      if let err = err {
        completionHandler(json, err)
      } else {
        completionHandler(json, nil)
      }
    }
  }
  
  
  func get(urlString: String, parameters: [String : AnyObject]? , tokenRequired:Bool=true, completionHandler: ((JSON?, NSError?) -> Void)) {
    requestAPI(.GET, urlString: urlString, parameters: parameters,tokenRequired: tokenRequired) { (json, err) -> Void in
      if let err = err {
        completionHandler(json, err)
      } else {
        completionHandler(json, nil)
      }
    }
  }
  
  
  //HTTP REQUEST
  func requestAPI(method: Method, urlString: String, parameters: [String : AnyObject]? ,tokenRequired:Bool = true, completionHandler: HttpCompletionHandler) {
    
    var headers = ["Content-Type":"application/json"]
    if let token = TokenPayload.sharedInstance.token where !token.isEmpty {
      print("request with token:\(token)")
      headers["Token"] = token
    } else {
      if tokenRequired {
        print("********* Token is required for [\(method)][\(urlString)] **********")
        return
      }
    }
    
    print(urlString)
    print(parameters)
    
    request(method, urlString, parameters: parameters, encoding: method == .GET ? .URLEncodedInURL : .JSON, headers: headers).response { (req, res, data, error) -> Void in
      self.handleResult(data, error: error, completionHandler: completionHandler)
    }
  }
  
  //HTTP REQUEST
  func requestTimeoutAPI(method: Method, urlString: String, parameters: [String : AnyObject]? ,tokenRequired:Bool = true, completionHandler: HttpCompletionHandler) {
    
    var headers = ["Content-Type":"application/json"]
    if let token = TokenPayload.sharedInstance.token  where !token.isEmpty{
      headers["Token"] = token
    } else {
      if tokenRequired {
        print("********* Token is required for [\(method)][\(urlString)] **********")
        return
      }
    }
    
    print(urlString)
    print(parameters)
    
    self.alamoFireManager.request(method, urlString, parameters: parameters, encoding: method == .GET ? .URLEncodedInURL : .JSON, headers: headers).response { (req, res, data, error) -> Void in
      self.handleResult(data, error: error, completionHandler: completionHandler)
    }
  }
  
  func handleResult(data:NSData?, error:NSError?, record:Bool = false ,completionHandler:HttpCompletionHandler) -> Void {
    if let error = error {
      print("api request fail:\(error)")
      completionHandler(nil,error)
    } else {
      print(self.jsonFromData(data))
      
      if let data = data {
        let json = JSON(data: data)
        if json["res"].int == 0 {
          completionHandler(json,nil)
          print(json["resDesc"].string)
        } else {
          var resDesc = ""
          if let key = json["res"].int {
            resDesc = ZKJSErrorMessages.sharedInstance.errorString("\(key)") ?? "错误码:\(key)"
          }
          let e = NSError(domain: NSBundle.mainBundle().bundleIdentifier ?? "com.zkjinshi.svip",
            code: json["res"].int ?? -1,
            userInfo: ["res":"\(json["res"].int)","resDesc":resDesc])
          completionHandler(json,e)
          print("error with reason: \(json["resDesc"].string)")
          if let key = json["res"].int,
            let msg = ZKJSErrorMessages.sharedInstance.errorString("\(key)") {
              //ZKJSTool.showMsg(msg)
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
