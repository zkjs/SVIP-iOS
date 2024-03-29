//
//  Httpservice+Account.swift
//  SVIP
//
//  Created by Qin Yejun on 3/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension HttpService {
  //// PAVO 认证服务API : 验证码 : HEADER不需要Token(注册获取验证码)
  func registerSmsCodeWithPhoneNumber(phone:String,completionHandler:HttpCompletionHandler){
    let urlString = ZKJSConfig.sharedInstance.BaseURL + ResourcePath.CodeRegister.description
    let key = "X2VOV0+W7szslb+@kd7d44Im&JUAWO0y"
    let data: NSData = phone.dataUsingEncoding(NSUTF8StringEncoding)!
    let encryptedData = data.AES256EncryptWithKey(key).base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    let dict = ["phone":"\(encryptedData)"]
    post(urlString, parameters: dict,tokenRequired: false) { (json, error) -> Void in
      completionHandler(json,error)
    }
    
  }
  
  
  //////注册流程 完善资料
  func updateUserInfo(isRegister: Bool, realname:String?,sex:String?,image:UIImage?,email:String?,silentmode:String?, completionHandler:HttpCompletionHandler) {
    if realname == nil && sex == nil && image == nil && email == nil && silentmode == nil {
      return
    }
    
    let urlString = isRegister ? ResourcePath.RegisterUpdata.description.fullUrl : ResourcePath.UserInfoUpdate.description.fullUrl
    
    var parameters = [String:String]()
    if isRegister {
      if let realname = realname {
        parameters["realname"] = realname
      }
    } else {
      if let realname = realname {
        parameters["username"] = realname
      }
    }
    if let sex = sex {
      parameters["sex"] = sex
    }
    if let email = email {
      parameters["email"] = email
    }
    
    if let silentmode = silentmode {
      parameters["silentmode"] = silentmode
    }
    guard  let token = TokenPayload.sharedInstance.token else {return}
    var headers = ["Content-Type":"multipart/form-data"]
    headers["Token"] = token
    
    upload(.POST, urlString,headers: headers,multipartFormData: {
      multipartFormData in
      if let image = image, let imageData = UIImageJPEGRepresentation(image, 1.0) {
        multipartFormData.appendBodyPart(data: imageData, name: "image", fileName: "image", mimeType: "image/png")
      }
      for (key, value) in parameters {
        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
      }
      
      }, encodingCompletion: {
        encodingResult in
        switch encodingResult {
        case .Success(let upload, _, _):
          upload.response(completionHandler: { (request, response, data, error) -> Void in
            print("statusCode:\(response?.statusCode)")
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
              if let data = data {
                let json = JSON(data: data)
                if json["res"].int == 0 {
                  
                  print(json["resDesc"].string)
                  
                  if isRegister {//注册更新会返回新的token
                    guard let token = json["token"].string else {
                      return
                    }
                    print(token)
                    let tokenPayload = TokenPayload.sharedInstance
                    tokenPayload.saveTokenPayload(token)
                    
                    //注册成功后订阅云巴
                    if let userID = tokenPayload.userID {
                      print("register userID:\(userID)")
                      YunbaSubscribeService.sharedInstance.setAlias(userID)
                    }
                  } else {//登陆后更新用户信息会返回不一样的数据结构，具体参考api文档
                    if let imgUrl = json["data"]["userimage"].string where !imgUrl.isEmpty {
                      AccountManager.sharedInstance().saveImageUrl(imgUrl)
                    }
                  }
                  
                  completionHandler(json,nil)
                  
                } else {
                  let e = NSError(domain: NSBundle.mainBundle().bundleIdentifier ?? "com.zkjinshi.svip",
                    code: -1,
                    userInfo: ["res":"\(json["res"].int)","resDesc":json["resDesc"].string ?? ""])
                  completionHandler(json,e)
                  print("error with reason: \(json["resDesc"].string)")
                  if let key = json["res"].int {
                    //ZKJSTool.showMsg("\(key)")
                  }
                }
              }
            }
          })
          
        case .Failure(let encodingError):
          let e = NSError(domain: NSBundle.mainBundle().bundleIdentifier ?? "com.zkjinshi.svip",
            code: 0,
            userInfo: ["res":"0","resDesc":"上传数据失败:)"])
          completionHandler(nil,e)
          print(encodingError)
        }
    })
    
  }
  
  func getUserinfo(completionHandler:HttpCompletionHandler?){
    let urlString = ResourcePath.UserInfo.description.fullUrl
    get(urlString, parameters: nil) { (json, error) -> Void in
      if let error = error {
        print(error)
      } else {
        if let userData = json?["data"].array?.first?.dictionary  {
          AccountManager.sharedInstance().saveBaseInfo(userData)
        }
      }
      completionHandler?(json,error)
    }
  }
  
  
  //根据邀请码查询销售员
  func querySalesFromCode(code:String,completionHandler:HttpCompletionHandler){
    let urlString =  ResourcePath.querySaleFromCode.description.fullUrl
    let dict = ["salecode":code]
    get(urlString, parameters: dict) { (json, error) -> Void in
      completionHandler(json,error)
      if let error = error {
        print(error)
      } else {
        completionHandler(json,nil)
      }
    }
  }
  //使用邀请码激活账号
  func codeActive(code:String,completionHandler:HttpCompletionHandler){
    let urlString = ResourcePath.ActiveCode.description.fullUrl
    let dic = ["salecode":code]
    get(urlString, parameters: dic) { (json, error) -> Void in
      completionHandler(json,error)
      if let error = error {
        print(error)
      } else {
        completionHandler(json,nil)
      }
    }
  }

}