//
//  SalesModel.swift
//  SVIP
//
//  Created by Hanton on 12/17/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class SalesModel: NSObject {
  
  var avg_score: NSNumber!
  var lasttime: String!
  var phone: NSNumber!
  var shop_name: String!
  var shopid: NSNumber!
  var userid: String!
  var username: String!
  
  override init() {
    super.init()
  }
  
  init(dictionary: [String: AnyObject]) {
    super.init()
    shop_name = dictionary["shop_name"] as? String ?? ""
    shopid = dictionary["shopid"] as? NSNumber ?? NSNumber(integer: 0)
    userid = dictionary["userid"] as? String ?? ""
    username = dictionary["username"] as? String ?? ""
    avg_score = dictionary["avg_score"] as? NSNumber ?? NSNumber(integer: 0)
    lasttime = dictionary["lasttime"] as? String ?? ""
    phone = dictionary["phone"] as? NSNumber ?? NSNumber(integer: 0)
  }
  
}
