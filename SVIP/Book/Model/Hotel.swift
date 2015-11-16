//
//  Hotel.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/23.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class Hotel: NSObject {
  var shopid: NSNumber!
  var logo: String!
  var logoURL: String! {
    get {
      let str = kBaseURL
      let str2 = "\(str)\(logo)"
      return str2
    }
  }
  var fullname: String!
  var phone: String!
  
  init(dic: NSDictionary) {
    let shopidString = dic["shopid"] as! String
    shopid = NSNumber(integer: Int(shopidString)!)
    logo = dic["logo"] as! String
    fullname = dic["fullname"] as? String
    phone = dic["phone"] as? String
  }
}
