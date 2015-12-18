//
//  Hotel.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/23.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class Hotel: NSObject {
  var shopid: String!
  var shoplogo: String!
  var saleid:String!
  var shopdesc: String!
  var shopname: String!
  var shopbusiness: String!
  var bgImgUrl: String!
  var shopaddress: String!
  override init() {
    super.init()
  }
  init(dic: NSDictionary) {
    
    shopid = dic["shopid"] as! String
    shoplogo = dic["shoplogo"] as! String
    saleid = dic["saleid"] as? String
    shopdesc = dic["shopdesc"] as? String
    shopname = dic["shopname"] as? String
    shopbusiness = dic["shopbusiness"] as? String
    bgImgUrl = dic["bgImgUrl"] as? String
    shopaddress = dic["shopaddress"] as? String
  }
}
