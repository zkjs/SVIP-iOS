//
//  Httpservice+Account.swift
//  SVIP
//
//  Created by Qin Yejun on 3/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension HttpService {
  //// PAVO 认证服务API : 验证码 : HEADER不需要Token(注册获取验证码)
  func registerSmsCodeWithPhoneNumber(phone:String,completionHandler:HttpCompletionHandler){
    let urlString = baseCodeURL + ResourcePath.CodeRegister.description
    let key = "X2VOV0+W7szslb+@kd7d44Im&JUAWO0y"
    let data: NSData = phone.dataUsingEncoding(NSUTF8StringEncoding)!
    let encryptedData = data.AES256EncryptWithKey(key).base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    let dict = ["phone":"\(encryptedData)"]
    post(urlString, parameters: dict,tokenRequired: false) { (json, error) -> Void in
      completionHandler(json,error)
    }
    
  }
  
  
  //////注册流程 完善资料
  func updateUserInfo(isRegister: Bool, realname:String?,sex:String?,image:UIImage?,email:String?, completionHandler:HttpCompletionHandler) {
    if realname == nil && sex == nil && image == nil && email == nil {
      return
    }
    
    let urlString = baseURLNewApi + (isRegister ? ResourcePath.RegisterUpdata.description : ResourcePath.UserInfoUpdate.description)
    
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
            if let error = error {
              print(error)
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
                    ZKJSTool.showMsg("\(key)")
                  }
                }
              }
            }
          })
          
        case .Failure(let encodingError):
          print(encodingError)
        }
    })
    
  }
  
  func getUserinfo(completionHandler:HttpCompletionHandler){
    let urlString = baseRegisterURL + ResourcePath.UserInfo.description
    get(urlString, parameters: nil) { (json, error) -> Void in
      completionHandler(json,error)
      if let error = error {
        print(error)
      } else {
        if let userData = json?["data"].array?.first?.dictionary  {
          AccountManager.sharedInstance().saveBaseInfo(userData)
        }
      }
    }
  }
}