//
//  HttpService+Token.swift
//  SVIP
//
//  Created by Qin Yejun on 3/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension HttpService {
  //// PAVO 认证服务API : 验证码 : HEADER不需要Token(登录)
  func requestSmsCodeWithPhoneNumber(phone:String,completionHandler:HttpCompletionHandler){
    let urlString = ResourcePath.CodeLogin.description.fullUrl
    let key = "X2VOV0+W7szslb+@kd7d44Im&JUAWO0y"
    let data: NSData = phone.dataUsingEncoding(NSUTF8StringEncoding)!
    let encryptedData = data.AES256EncryptWithKey(key).base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    let dict = ["phone":"\(encryptedData)"]
    post(urlString, parameters: dict,tokenRequired: false) { (json, error) -> Void in
      completionHandler(json,error)
    }
    
  }
  
  
  ////注册使用验证码获取token
  func registerWithPhoneNumber(phone:String,code:String,completionHandler:HttpCompletionHandler) {
    let urlString = ResourcePath.register.description.fullUrl
    let dict = ["phone":"\(phone)","code":code]
    post(urlString, parameters: dict,tokenRequired: false) { (json, error) -> Void in
      if let token = json?["token"].string where !token.isEmpty {
        TokenPayload.sharedInstance.saveTokenPayload(token)
      }
      completionHandler(json,error)
    }
    
  }
  
  
  //// PAVO 认证服务API : 使用手机验证码创建Token : HEADER不需要Token
  func loginWithCode(code:String,phone:String,completionHandler:HttpCompletionHandler) {
    let urlString = ResourcePath.Login.description.fullUrl
    
    let dict = ["phone":"\(phone)","code":"\(code)"]
    post(urlString, parameters: dict, tokenRequired: false) { (json, error) -> Void in
      if let json = json {
        guard let token = json["token"].string where !token.isEmpty else {
          print("no token")
          completionHandler(nil, error)
          return
        }
        
        let tokenPayload = TokenPayload.sharedInstance
        if let res = json["res"].int where res == 11 {// 未完善资料
          tokenPayload.saveTemporaryTokenPayload(token)
        } else {
          tokenPayload.saveTokenPayload(token)
        }
        
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
  
  //// PAVO 认证服务API : Token管理 : 刷新Token
  func managerToken(completionHandler:HttpCompletionHandler) {
    let urlString = ResourcePath.Token.description.fullUrl
    
    self.refreshTokenTime = NSDate().timeIntervalSince1970
    
    put(urlString, parameters: nil) { (json, error) -> Void in
      completionHandler(json, error)
      if let json = json {
        guard let token = json["token"].string where !token.isEmpty else {
          completionHandler(nil, error)
          print("no token")
          return
        }
        print("success")
        print("refresh token:\(token)")
        let tokenPayload = TokenPayload.sharedInstance
        tokenPayload.saveTokenPayload(token)
        
      }
    }
  }
  
  //// PAVO 认证服务API : Token管理 :
  func deleteToken(completionHandler:HttpCompletionHandler?) {
    let urlString = ResourcePath.Token.description.fullUrl
    guard   let token = TokenPayload.sharedInstance.token else {return}
    let dic = ["token":token]
    put(urlString, parameters: dic) { (json, error) -> Void in
      completionHandler?(json, error)
    }
  }
  
}