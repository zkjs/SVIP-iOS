//
//  AccountManager.swift
//  SVIP
//
//  Created by Hanton on 12/14/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit
import SwiftyJSON

class AccountManager: NSObject {

  private(set) var deviceToken = ""
  private(set) var userID = ""
  private(set) var token = ""
//  private(set) var avatarImage = UIImage(named: "logo_white")
  private(set) var userName = ""
  private(set) var sex = 1 // 0女 1男
  private(set) var email = ""
  private(set) var phone = ""
  private(set) var invoice = ""
  private(set) var activated = "0"
  private(set) var realname = ""
  private(set) var userstatus = 0
  private(set) var viplevel = 0
  private(set) var password = ""
  private(set) var payCreatetime = ""
  var avatarURL : String {
    let userDefaults = NSUserDefaults()
    if let url = userDefaults.objectForKey("avatarURL") as? String {
      return url.fullImageUrl
    } else {
      return ""
    }
  }
  
  var sexName: String? {
    get {
      if sex == 1 {
        return "男"
      } else if sex == 0 {
        return "女"
      } else {
        return nil
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
    //avatarURL = userDefaults.objectForKey("avatarURL") as? String ?? ""
//    if let url = NSURL(string: avatarURL) {
//      if let imageData = NSData(contentsOfURL: url) {
//        if let image = UIImage(data: imageData) {
//          avatarImage = image
//        }
//      }
//    }
    userName = userDefaults.objectForKey("userName") as? String ?? ""
    sex = userDefaults.objectForKey("sex") as? Int ?? 0
    email = userDefaults.objectForKey("email") as? String ?? ""
    phone = userDefaults.objectForKey("phone") as? String ?? ""
    invoice = userDefaults.objectForKey("invoice") as? String ?? ""
    activated = userDefaults.objectForKey("activated") as? String ?? "0"
    userstatus = userDefaults.objectForKey("userstatus") as? Int ?? 0
    viplevel = userDefaults.objectForKey("viplevel") as? Int ?? 0
    realname = userDefaults.objectForKey("realname") as? String ?? "0"
    password = userDefaults.objectForKey("password") as? String ?? "0"
    payCreatetime = userDefaults.objectForKey("payCreatetime") as? String ?? ""
    
  }
  
  func isLogin() -> Bool {
    return (userID.isEmpty == false && token.isEmpty == false)
  }
  
  func saveBaseInfo(json: [String:JSON]) {
    let imgURL  = json["userimage"]?.string ?? ""
//    if let url = NSURL(string: imgURL) {
//      if let imageData = NSData(contentsOfURL: url) {
//        if let image = UIImage(data: imageData) {
//          avatarImage = image
//        }
//      }
//    }
    userID = json["userid"]?.string ?? ""
    userName = json["username"]?.string ?? ""
    sex =  json["sex"]?.int ?? 0
    email = json["email"]?.string ?? ""
    phone = json["phone"]?.string ?? ""
    userstatus = json["userstatus"]?.int ?? 0
    viplevel = json["viplevel"]?.int ?? 0
    password = json["password"]?.string ?? ""
    realname = json["realname"]?.string ?? ""
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(imgURL, forKey: "avatarURL")
    userDefaults.setObject(userName, forKey: "userName")
    userDefaults.setObject(sex, forKey: "sex")
    userDefaults.setObject(email, forKey: "email")
    userDefaults.setObject(phone, forKey: "phone")
    userDefaults.setObject(activated, forKey: "activated")
    userDefaults.setObject(viplevel, forKey: "viplevel")
    userDefaults.setObject(realname, forKey: "realname")
    userDefaults.setObject(userstatus, forKey: "userstatus")
    userDefaults.setObject(password, forKey: "password")
    userDefaults.synchronize()
  }
  
    
  func saveDeviceToken(deviceToken: String) {
    self.deviceToken = deviceToken
  }

  
  func saveUserName(userName: String) {
    self.userName = userName
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(userName, forKey: "userName")
  }
  
  func saveInvoice(invoice: String) {
    self.invoice = invoice
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(invoice, forKey: "invoice")
  }
  
//  func saveAvatarImageData(imageData: NSData) {
//    if let image = UIImage(data: imageData) {
//      avatarImage = image
//    }
//  }
  
  func saveActivated(activated: String) {
    self.activated = activated
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(activated, forKey: "activated")
  }
  
  
  func saveSex(sex: Int) {
    self.sex = sex
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(sex, forKey: "sex")
    userDefaults.synchronize()
  }
  
  func saveEmail(email: String) {
    self.email = email
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(email, forKey: "email")
    userDefaults.synchronize()
  }
  
  func saveImageUrl(url: String) {
    if url.isEmpty { return }
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(url, forKey: "avatarURL")
    userDefaults.synchronize()
  }
  
   func savePayCreatetime(payCreatetime: String) {
    if payCreatetime.isEmpty { return }
    let userDefaults = NSUserDefaults()
    userDefaults.setObject(payCreatetime, forKey: "payCreatetime")
    userDefaults.synchronize()
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
    userDefaults.setObject(nil, forKey: "invoice")
    userDefaults.setObject(nil, forKey: "activated")
    userDefaults.setObject(nil, forKey: "userstatus")
    userDefaults.setObject(nil, forKey: "password")
    userDefaults.setObject(nil, forKey: "viplevel")
    userDefaults.setObject(nil, forKey: "realname")
    userDefaults.synchronize()
    
    userID = ""
    token = ""
//    avatarImage = UIImage(named: "logo_white")
    userName = ""
    sex = 1
    email = ""
    phone = ""
    invoice = ""
    activated = ""
    realname = ""
    userstatus = 0
    viplevel = 0
    password = ""
  }
  
}
