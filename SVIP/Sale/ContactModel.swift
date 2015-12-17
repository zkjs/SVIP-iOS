//
//  ContactModel.swift
//  SVIP
//
//  Created by AlexBang on 15/11/28.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class ContactModel: NSObject {
  var created: String!
  var fname: String!
  var fuid:String!
  var id: String!
  var phone: String!
  var shop_name: String!
  var shopid: String!
  var teamid: String!
  var userid: String!
  
  init(dic:[String:AnyObject]) {
    created = dic["created"] as? String
    fname = dic["fname"] as? String
    fuid = dic["fuid"] as? String
    id = dic["id"] as? String
    phone = dic["phone"] as? String
    shop_name = dic["shop_name"] as? String
    shopid = dic["shopid"] as? String
    teamid = dic["teamid"] as? String
    userid = dic["userid"] as? String
  }
}
