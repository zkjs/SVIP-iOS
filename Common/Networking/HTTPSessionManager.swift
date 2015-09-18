//
//  HTTPSessionManager.swift
//  BeaconMall
//
//  Created by Hanton on 4/24/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import Foundation

enum NetworkCondition: Int {
  case Unknown
  case ReachableViaWWAN
  case ReachableViaWiFi
  case NotReachable
}

class HTTPSessionManager: AFHTTPSessionManager {
  
  class func sharedInstance() -> HTTPSessionManager {
    struct Singleton {
      static let instance = HTTPSessionManager(baseURL: NSURL(string: "http://120.25.241.196/"))
    }
    
    return Singleton.instance
  }
  
  init(baseURL url: NSURL!) {
    super.init(baseURL: url, sessionConfiguration: nil)
    
    requestSerializer = AFHTTPRequestSerializer()
    responseSerializer = AFJSONResponseSerializer()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func userSignUpWith(phone phone: String, password: String, sex: String, success: (NSURLSessionDataTask!, AnyObject!) -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
    let md5_password = NSString.MD5String(password)() // MD5密码
    let phone_os = UIDevice.currentDevice().systemVersion // 系统版本
    let map_longitude = "23.12" // 纬度
    let map_latitude = "108.23" // 经度
    let os = "3" // WEB'1' 安卓'2' 苹果'3' 其他'4'
    let userstatus = "2" // 用户状态 注册用户为 ‘2’，快捷匿名用户为 ‘3’
    let bluetooth_key = UIDevice.currentDevice().identifierForVendor!.UUIDString // 手机唯一标示
    
    var RegForm = [String: String]()
    RegForm["phone"] = phone
    RegForm["password"] = md5_password
    RegForm["sex"] = sex
    RegForm["phone_os"] = phone_os
    RegForm["map_longitude"] = map_longitude
    RegForm["map_latitude"] = map_latitude
    RegForm["os"] = os
    RegForm["userstatus"] = userstatus
    RegForm["bluetooth_key"] = bluetooth_key
    
    let parameters = [
      "RegForm":RegForm
    ]
    
    POST("index.php?r=user/reg",
      parameters: parameters,
      success: { (task: NSURLSessionDataTask!,responseObject: AnyObject!) -> Void in
        print(responseObject.description)
        success(task, responseObject)
      },
      failure: { (task: NSURLSessionDataTask!,error: NSError!) -> Void in
        print(error.localizedDescription)
        failure(task, error)
    })
  }
  
//  func requestSmsCodeWithPhoneNumber(#phone: String, callback: (Bool!, NSError!) -> Void) -> Void {
//    AVOSCloud.requestSmsCodeWithPhoneNumber(phone, callback: { (success: Bool, error: NSError!) -> Void in
//      callback(success, error)
//    })
//  }
//  
//  func verifySmsCode(#code: String, phone: String, callback: (Bool!, NSError!) -> Void) -> Void {
//    AVOSCloud.verifySmsCode(code, mobilePhoneNumber: phone) { (success: Bool, error: NSError!) -> Void in
//      callback(success, error)
//    }
//  }
  
  func visitorSignUp(success success: (NSURLSessionDataTask!, AnyObject!) -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
    let userstatus = "3" // 用户状态 注册用户为 ‘2’，快捷匿名用户为 ‘3’
    let bluetooth_key = UIDevice.currentDevice().identifierForVendor!.UUIDString // 手机唯一标示
    let os = "3" // WEB'1' 安卓'2' 苹果'3' 其他'4'
    
    var LoginForm = [String: String]()
    LoginForm["os"] = os
    LoginForm["userstatus"] = userstatus
    LoginForm["bluetooth_key"] = bluetooth_key
    
    let parameters = [
      "LoginForm":LoginForm
    ]
    
    POST("index.php?r=user/login",
      parameters: parameters,
      success: { (task: NSURLSessionDataTask!,responseObject: AnyObject!) -> Void in
        print(responseObject.description)
        success(task, responseObject)
      },
      failure: { (task: NSURLSessionDataTask!,error: NSError!) -> Void in
        print(error.localizedDescription)
        failure(task, error)
    })
  }
  
  func userLoginWith(phone phone: String, password: String, rememberMe: String, success: ( NSURLSessionDataTask!, AnyObject!) -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
    let phone_os = UIDevice.currentDevice().systemVersion // 系统版本
    let map_longitude = "23.12" // 纬度
    let map_latitude = "108.23" // 经度
    let login_type = "1" // 登录类型 手机 默认1
    
    var LoginForm = [String: String]()
    LoginForm["phone"] = phone
    LoginForm["password"] = NSString.MD5String(password)()
    LoginForm["rememberMe"] = rememberMe
    LoginForm["login_type"] = login_type
    LoginForm["phone_info"] = phone_os
    LoginForm["map_longitude"] = map_longitude
    LoginForm["map_latitude"] = map_latitude
    
    let parameter = [
      "LoginForm":LoginForm
    ]
    
    POST("index.php?r=user/login", parameters: parameter,
      success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        print(responseObject.description)
        success(task, responseObject)
      },
      failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        print(error.localizedDescription)
        failure(task, error)
    })
  }
  
  func checkDuplicatePhone(phone phone: String, success: ( NSURLSessionDataTask!, AnyObject!) -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
    GET("index.php?r=user/reg&phone="+phone, parameters: nil,
      success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        print(responseObject.description)
        success(task, responseObject)
      },
      failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        print(error.localizedDescription)
        failure(task, error)
    })
  }
  
  func updateUserInfo(userID userID: String, token: String, userName: String, imageData: NSData, imageName: String, success: (NSURLSessionDataTask!, AnyObject!) -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
    POST("index.php?r=user/upload", parameters: nil, constructingBodyWithBlock: { (formData:AFMultipartFormData!) -> Void in
      formData.appendPartWithFileData(imageData, name: "UploadForm[file]", fileName: imageName, mimeType: "image/jpeg")
      formData.appendPartWithFormData(userID.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "UploadForm[userid]")
      formData.appendPartWithFormData(token.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "UploadForm[token]")
      formData.appendPartWithFormData(userName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "UploadForm[username]")
      }, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        print(responseObject.description)
        success(task, responseObject)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        print(error.localizedDescription)
        failure(task, error)
    }
  }
  
  func getUserProfile(userID userID: String) -> UIImage {
    let url = NSURL(string: "http://120.25.241.196/uploads/users/"+userID+".jpg")
    let imageData = NSData(contentsOfURL: url!)
    let image = UIImage(data: imageData!)
    return image!
  }
  
  func getUserInfo(userID userID: String, token: String, success: ( NSURLSessionDataTask!, AnyObject!) -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
    GET("index.php?r=user/select&userid="+userID+"&token="+token, parameters: nil,
      success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        print(responseObject.description)
        success(task, responseObject)
      },
      failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        print(error.localizedDescription)
        failure(task, error)
    })
  }
  
  func getShopInfo(shopID shopID: String, success: ( NSURLSessionDataTask!, AnyObject!) -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
    GET("index.php?r=shop/select&shopid=\(shopID)&web=0", parameters: nil,
      success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        print(responseObject.description)
        success(task, responseObject)
      },
      failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        print(error.localizedDescription)
        failure(task, error)
    })
  }
  
  func getAllShopInfo(start start: Int, page: Int, key: String, isDesc: Bool, success: ( NSURLSessionDataTask!, AnyObject!) -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
    var desc = ""
    if isDesc {
      desc = "desc"
    } else {
      desc = "asc"
    }
    GET("index.php?r=shop/select&stat="+String(start)+"&page="+String(page)+"&key="+String(key)+"&desc="+desc+"&web=0", parameters: nil,
      success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
//        println(responseObject.description)
        success(task, responseObject)
      },
      failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        print(error.localizedDescription)
        failure(task, error)
    })
  }
  
  func getShopComments(shopID shopID: String, start: Int, page: Int, key: String, isDesc: Bool, success: ( NSURLSessionDataTask!, AnyObject!) -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
    var desc = ""
    if isDesc {
      desc = "desc"
    } else {
      desc = "asc"
    }
    GET("index.php?r=shop/comment&shopid="+shopID+"&stat="+String(start)+"&page="+String(page)+"&key="+String(key)+"&desc="+desc+"&web=0", parameters: nil,
      success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        print(responseObject.description)
        success(task, responseObject)
      },
      failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        print(error.localizedDescription)
        failure(task, error)
    })
  }
  
  func reachabilityStatus(callback: (AFNetworkReachabilityStatus) -> Void) -> Void {
    reachabilityManager.startMonitoring()
    reachabilityManager.setReachabilityStatusChangeBlock { [unowned self] (status: AFNetworkReachabilityStatus) -> Void in
      switch status {
      case AFNetworkReachabilityStatus.Unknown:
        print("AFNetworkReachabilityStatus.Unknown")
      case AFNetworkReachabilityStatus.ReachableViaWWAN:
        print("AFNetworkReachabilityStatus.ReachableViaWWAN")
      case AFNetworkReachabilityStatus.ReachableViaWiFi:
        print("AFNetworkReachabilityStatus.ReachableViaWiFi")
      case AFNetworkReachabilityStatus.NotReachable:
        print("AFNetworkReachabilityStatus.NotReachable")
      }
      
      callback(status)
      self.reachabilityManager.stopMonitoring()
    }
  }
   
}
