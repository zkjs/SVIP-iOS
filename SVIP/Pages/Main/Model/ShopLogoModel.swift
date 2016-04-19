//
//  ShopLogoModel.swift
//  SVIP
//
//  Created by Qin Yejun on 4/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShopLogoModel: NSObject,NSCoding {
  
  var locid: String = ""          //区域id
  var shopid: String = ""         //商户id
  var shopname: String = ""       //商户名称
  var changetime:NSDate           //变更时间
  var validthru:NSDate            //当前logo有效期截止时间
  private var originLogo:String = "" //商户logo
  var logo: String {
    if originLogo.isEmpty {
      return ""
    }
    if DeviceType.IS_IPHONE_6P {
      return "\(originLogo)@420h.png"
    } else if DeviceType.IS_IPHONE_6 {
      return "\(originLogo)@280h.png"
    }
    return "\(originLogo)@220h.png"
  }
  
  init(dic: NSDictionary) {
    locid = dic["locid"] as? String ?? ""
    shopid = dic["shopid"] as? String ?? ""
    shopname = dic["shopname"] as? String ?? ""
    originLogo = dic["logo"] as? String ?? ""
    changetime = NSDate.dateFromString(dic["changetime"] as? String ?? "") ?? NSDate()
    validthru = NSDate.dateFromString(dic["validthru"] as? String ?? "") ?? NSDate()
  }
  
  init(json:JSON) {
    locid = json["locid"].string ?? ""
    shopid = json["shopid"].string ?? ""
    shopname = json["shopname"].string ?? ""
    originLogo = json["logo"].string ?? ""
    changetime = NSDate.dateFromString(json["changetime"].string ?? "") ?? NSDate()
    validthru = NSDate.dateFromString(json["validthru"].string ?? "") ?? NSDate()
  }
  
  init(locid:String, shopid:String, shopname:String, logo:String, changetime:NSDate, validthru:NSDate) {
    self.locid = locid
    self.shopid = shopid
    self.shopname = shopname
    self.originLogo = logo
    self.changetime = changetime
    self.validthru = validthru
  }
  
  
  // MARK: NSCoding
  
  required convenience init?(coder decoder: NSCoder) {
    guard let locid = decoder.decodeObjectForKey("locid") as? String,
      let shopid = decoder.decodeObjectForKey("shopid") as? String,
      let shopname = decoder.decodeObjectForKey("shopname") as? String,
      let originLogo = decoder.decodeObjectForKey("originLogo") as? String,
      let changetime = decoder.decodeObjectForKey("changetime") as? NSDate,
      let validthru = decoder.decodeObjectForKey("validthru") as? NSDate
      else { return nil }
    
    self.init(locid:locid, shopid:shopid, shopname:shopname, logo:originLogo, changetime:changetime, validthru:validthru)
  }
  
  func encodeWithCoder(coder: NSCoder) {
    coder.encodeObject(self.locid, forKey: "locid")
    coder.encodeObject(self.shopid, forKey: "shopid")
    coder.encodeObject(self.shopname, forKey: "shopname")
    coder.encodeObject(self.originLogo, forKey: "originLogo")
    coder.encodeObject(self.changetime, forKey: "changetime")
    coder.encodeObject(self.validthru, forKey: "validthru")
  }
}
