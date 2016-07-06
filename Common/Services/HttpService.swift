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
import Alamofire
import SwiftyJSON

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
  
  var beaconRetryCount = 0              // beacon 上传失败后重新请求当前次数
  let maxBeaconRetryCount = 3           // beacon 上传失败后重新请求最多次数
  let beaconRetryDelay = 5              // beacon 上传失败后重新请求延迟时间
  
  var refreshTokenTime: NSTimeInterval = NSDate().timeIntervalSince1970
  
  // 豪庭
  //static let DIST = "568e8db288b8a95d7ecfeb9a5d6936b9c521253f3cad30cd9b83ed2d87db9605"
  enum ResourcePath: CustomStringConvertible {
    case ApiURL(path:String)            // demo
    case Beacon                         // PYXIS 位置服务API : Beacon 位置信息 :
    case MultiBeacon                    // PYXIS 位置服务API : 一次上传多个beacon信息
    case GPS                            // PYXIS 位置服务API : GPS 位置信息 :
    case UploadBeacons                  // 上传用户收集到的所有beacon信息
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
    case MyShops                        // 我的商家
    case MyCards                        // 我的会员卡
    case ShopComments(shopid:String)    // 商家评论
    case querySaleFromCode              // 根据邀请码查询销售员
    case ActiveCode                     // 邀请码激活
    case HomePicture                    // 首页大图
    case HomePrivilegeIntro             // 首页大图
    case HomeRecom(city:String)         // 首页服务推荐
    case HomeAllMessages(city:String)   // 登陆用户首页详情-订单-特权
    case CheckVersion(version:String)   // 检查App版本
    case UserEnsurePay                  // 用户确认付款
    case PaymentInfo                    // 获取首付款列表，含明细
    case Balance                        // 账户余额
    case ServiceTag                     // 商家提供服务列表
    case Myorders                       // 我的呼叫服务列表
    case CreateOrder                    // 创建呼叫服务
    case BeaconAreas                    // 获取商家区域列表
    case RatingOrder                    // 评价服务
    case MySchedule                     // 我的行程列表
    case AttendActivity                 // 参加活动
    case QuitActivity                   // 退出活动
     
    
    var description: String {
      switch self {
      case .ApiURL(let path):           return "/api/\(path)"
      case .Beacon:                     return "/pyx/lbs/v1/loc/beacon"
      case .MultiBeacon:                return "/pyx/lbs/v2/loc/beacon"
      case .GPS:                        return "/pyx/lbs/v1/loc/gps"
      case .UploadBeacons:              return "/pyx/lbs/v1/loc/beacons"
      //case .CodeLogin:                return "/pav/sso/vcode/v1/si?source=login&dist=\(DIST)"
      //case .CodeRegister:             return "/pav/sso/vcode/v1/si?source=register&dist=\(DIST)"
      //case .Login:                    return "/pav/sso/token/v1/phone/si?dist=\(DIST)"
      case .CodeLogin:                  return "/pav/sso/vcode/v1/si?source=login"
      case .CodeRegister:               return "/pav/sso/vcode/v1/si?source=register"
      case .Login:                      return "/pav/sso/token/v1/phone/si"
      case .Token:                      return "/pav/sso/token/v1"
      case .DeleteToken:                return "/pav/sso/token/v1"
      //case .register:                 return "/pav/res/v1/register/si?dist=\(DIST)"
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
      case .HomeAllMessages(let city):  return "/for/res/v1/system/sihomedetail/\(city)"
      case .CheckVersion(let version):  return "/for/res/v1/systempub/upgrade/newestversion/1/IOS/\(version)"
      case .UserEnsurePay:              return "/for/res/v1/payment"
      case .PaymentInfo:                return "/for/res/v1/payment/si"
      case .Balance:                    return "/for/res/v1/payment/balance"
      case .MyShops:                    return "/for/res/v1/shop/belong/si"
      case .MyCards:                    return "/for/res/v1/payment/balance/list"
      case .ServiceTag:                 return "/for/res/v1/call/servicetag"
      case .Myorders:                   return "/for/res/v1/call/service/task"
      case .CreateOrder:                return "/for/res/v1/call/service/task"
      case .BeaconAreas:                return "/for/lbs/v1/loc/beacon"
      case .RatingOrder:                return "/for/res/v1/call/service/task"
      case .MySchedule:                 return "/for/res/v1/activity/detail"
      case .AttendActivity:             return "/for/res/v1/activity/confirm"
      case .QuitActivity:               return "/for/res/v1/activity/confirm"
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
  func requestAPI(method: Alamofire.Method, urlString: String, parameters: [String : AnyObject]? ,tokenRequired:Bool = true, completionHandler: HttpCompletionHandler) {
    
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
      self.handleResult(request:req, response: res, data: data, error: error, completionHandler: completionHandler)
    }
  }
  
  //HTTP REQUEST
  func requestTimeoutAPI(method: Alamofire.Method, urlString: String, parameters: [String : AnyObject]? ,tokenRequired:Bool = true, completionHandler: HttpCompletionHandler) {
    
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
      self.handleResult(request:req, response: res, data: data, error: error, completionHandler: completionHandler)
    }
  }
  
  func handleResult(request request:NSURLRequest?, response:NSHTTPURLResponse?,data:NSData?, error:NSError?, record:Bool = false ,completionHandler:HttpCompletionHandler) -> Void {
    print("statusCode:\(response?.statusCode) for url:\(request?.URL?.absoluteString)")
    guard let statusCode = response?.statusCode else{
      let e = NSError(domain: NSBundle.mainBundle().bundleIdentifier ?? "com.zkjinshi.svip",
                      code: 0,
                      userInfo: ["res":"0","resDesc":"未知网络错误:)"])
      completionHandler(nil,e)
      return
    }
    if statusCode == 401 {//token过期
      // 由于异步请求，其他请求在token刷新后立即到达server会被判定失效，导致用户被登出
      if NSDate().timeIntervalSince1970 > self.refreshTokenTime + 100 {
        print("invalid token:\(request)")
        TokenPayload.sharedInstance.clearCacheTokenPayload()
        NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGOUTCHANGE, object: nil)
        let e = NSError(domain: NSBundle.mainBundle().bundleIdentifier ?? "com.zkjinshi.svip",
                        code: 401,
                        userInfo: ["res":"401","resDesc":"invalid token"])
        
        completionHandler(nil,e)
        completionHandler(nil,e)
        return
      }
    } else if statusCode != 200 {
      let e = NSError(domain: NSBundle.mainBundle().bundleIdentifier ?? "com.zkjinshi.svip",
        code: statusCode,
        userInfo: ["res":"\(statusCode)","resDesc":"网络错误:\(statusCode)"])
      completionHandler(nil,e)
      return
    }
    
    if let error = error {
      print("api request fail [res code:,\(response?.statusCode)]:\(error)")
      completionHandler(nil,error)
    } else {
      print(self.jsonFromData(data))
      
      if let data = data where data.length > 0 {
        let json = JSON(data: data)
        if json["res"].int == 0 {
          completionHandler(json,nil)
          print(json["resDesc"].string)
        } else {
          var resDesc = ""
          if let key = json["res"].int {
            resDesc = ZKJSErrorMessages.sharedInstance.errorString("\(key)") ?? (json["resDesc"].string != nil ? json["resDesc"].string! : "错误码:\(key)")
          }
          if let key = json["res"].int where key == 6 || key == 8 {//token过期
            NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGOUTCHANGE, object: nil)
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
          userInfo: ["res":"-2","resDesc": "服务器返回空数据"])
        completionHandler(nil,e)
        print("error with reason: \(e)")
      }
    }
  }
  
}
