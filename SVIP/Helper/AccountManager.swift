//
//  AccountManager.swift
//  SVIP
//
//  Created by Hanton on 12/14/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class AccountManager: NSObject {

  private(set) var deviceToken = ""
  private(set) var userID = ""
  private(set) var token = ""
  private(set) var avatarURL = ""
  private(set) var avatarImage = UIImage()
  private(set) var userName = ""
  private(set) var sex = "0" // 0男 1女
  private(set) var email = ""
  private(set) var phone = ""
  
  var sexName: String {
    get {
      if sex == "0" {
        return "男"
      } else {
        return "女"
      }
    }
  }
  
  class func sharedInstance() -> AccountManager {
    struct Singleton {
      static let instance = AccountManager()
    }
    return Singleton.instance
  }
  
  override init() {
    let userDefaults = NSUserDefaults()
    userID = userDefaults.objectForKey("userID") as? String ?? ""
    token = userDefaults.objectForKey("token") as? String ?? ""
    avatarURL = userDefaults.objectForKey("avatarURL") as? String ?? ""
    if let url = NSURL(string: avatarURL) {
      if let imageData = NSData(contentsOfURL: url) {
        if let image = UIImage(data: imageData) {
          avatarImage = image
        }
      }
    }
    userName = userDefaults.objectForKey("userName") as? String ?? ""
    sex = userDefaults.objectForKey("sex") as? String ?? ""
    email = userDefaults.objectForKey("email") as? String ?? ""
    phone = userDefaults.objectForKey("phone") as? String ?? ""
  }
  
  func isLogin() -> Bool {
    return (userID.isEmpty == false && token.isEmpty == false)
  }
  
  func saveAccountInfo(accountInfo: [String: AnyObject]) {
    if let userid = accountInfo["userid"] as? String,
      let token = accountInfo["token"] as? String {
        userID = userid
        self.token = token
        let userDefaults = NSUserDefaults()
        userDefaults.setObject(userid, forKey: "userID")
        userDefaults.setObject(token, forKey: "token")
    } else {
      print("弹框，返回的userid或token为空")
    }
  }
  
  func saveBaseInfo(baseInfo: [String: AnyObject]) {
    avatarURL = kBaseURL + "uploads/users/\(userID).jpg"
    if let url = NSURL(string: avatarURL) {
      if let imageData = NSData(contentsOfURL: url) {
        if let image = UIImage(data: imageData) {
          avatarImage = image
        }
      }
    }
    userName = baseInfo["username"] as? String ?? ""
    sex =  baseInfo["sex"] as? String ?? ""
    email = baseInfo["email"] as? String ?? ""
    phone = baseInfo["phone"] as? String ?? ""
    
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(avatarURL, forKey: "avatarURL")
    userDefaults.setObject(userName, forKey: "userName")
    userDefaults.setObject(sex, forKey: "sex")
    userDefaults.setObject(email, forKey: "email")
    userDefaults.setObject(phone, forKey: "phone")
  }
  
  func saveDeviceToken(deviceToken: String) {
    self.deviceToken = deviceToken
  }
  
  func saveUserName(userName: String) {
    self.userName = userName
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(userName, forKey: "userName")
  }
  
  func saveAvatarImageData(imageData: NSData) {
    if let image = UIImage(data: imageData) {
      avatarImage = image
    }
  }
  
  func saveSex(sex: String) {
    self.sex = sex
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(sex, forKey: "sex")
  }
  
  func saveEmail(email: String) {
    self.email = email
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(email, forKey: "email")
  }
  
  func clearAccountCache() {
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(nil, forKey: "userID")
    userDefaults.setObject(nil, forKey: "token")
    userDefaults.setObject(nil, forKey: "avatarURL")
    userDefaults.setObject(nil, forKey: "userName")
    userDefaults.setObject(nil, forKey: "sex")
    userDefaults.setObject(nil, forKey: "email")
    userDefaults.setObject(nil, forKey: "phone")
    userDefaults.synchronize()
    
    userID = ""
    token = ""
    avatarURL = ""
    avatarImage = UIImage()
    userName = ""
    sex = ""
    email = ""
    phone = ""
  }
  
}
