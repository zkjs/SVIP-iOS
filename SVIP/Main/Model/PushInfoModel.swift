//
//  PushInfoModel.swift
//  SVIP
//
//  Created by AlexBang on 15/12/16.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class PushInfoModel: NSObject {
  
  var desc: String!
  var iconbaseurl: String!
  var iconfilename: String!
  var shopid: String!
  var shopName: String!
  var title: String!
  var orderNo: String!
  
  override init() {
    super.init()
  }
  
  init(dic: NSDictionary) {
    if let shopid = dic["shopid"] as? String {
      self.shopid = shopid
    } else {
//      ZKJSTool.showMsg("shopid无值\(dic)")
    }
    if let orderNo = dic["orderNo"] as? String {
      self.orderNo = orderNo
    } else {
//      ZKJSTool.showMsg("orderNo无值\(dic)")
    }
    if let shopName = dic["shopName"] as? String {
      self.shopName = shopName
    } else {
//      ZKJSTool.showMsg("shopName无值\(dic)")
    }
    desc = dic["desc"] as? String ?? ""
    iconbaseurl = dic["iconbaseurl"] as? String ?? ""
    iconfilename = dic["iconfilename"] as? String ?? ""
    title = dic["title"] as? String ?? ""
  }
  
  init(json:JSON) {
    desc = json["desc"].string ?? ""
    iconfilename = json["iconfilename"].string ?? ""
    shopName = json["shopName"].string ?? ""
    shopid = json["shopid"].string ?? ""
    title = json["title"].string ?? ""
    
    iconbaseurl = json["iconbaseurl"].string ?? ""
    orderNo = json["orderno"].string ?? ""
    if let icon = json["icon"].string {
      self.iconfilename = icon
    }
    if let shopname = json["shopname"].string {
      self.shopName = shopname
    }
    
  }
  
}
