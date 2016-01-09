//
//  OrderListModel.swift
//  SVIP
//
//  Created by AlexBang on 15/12/29.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
/**
 * 订单状态(0:未确认 1:已确认 2:已取消)
 */
class OrderListModel: NSObject {
  var orderno: String!
  var shopid: String!
  var userid: String!
  var shopname: String!
  var shoplogo: String!
  var productid: String!
  var roomno: String!
  var roomcount: NSNumber!
   var orderstatus: String!
  var roomtype: String!
  var roomprice: double_t!
  var orderedby: String!
  var telephone: String!
  var arrivaldate: NSDate!
  var leavedate: NSDate!
  var created: NSDate!
  var saleid:String!
  var username:String!
  
  
  override init() {
    super.init()
  }
  
  init(dic: NSDictionary) {
    orderno = dic["orderno"] as? String ?? ""
    shopid = dic["shopid"] as? String ?? ""
    userid = dic["userid"] as? String ?? ""
    shopname = dic["shopname"] as? String ?? ""
    shoplogo = dic["shoplogo"] as? String ?? ""
    productid = dic["productid"] as? String ?? ""
    roomno = dic["roomno"] as? String ?? ""
    roomtype = dic["roomtype"] as? String ?? ""
    roomprice = dic["roomprice"] as? double_t ??  double_t(0.0)
    roomcount = dic["roomcount"] as? NSNumber ?? NSNumber(double: 0.0)
    orderstatus = dic["orderstatus"] as? String ?? ""
    orderedby = dic["orderedby"] as? String ?? ""
    telephone = dic["telephone"] as? String ?? ""
    username = dic["username"] as? String ?? ""
    saleid = dic["saleid"] as? String ?? ""
    arrivaldate = dic["arrivaldate"] as? NSDate ?? NSDate()
    if let timestamp =  dic["created"] as? NSNumber {
      created = NSDate(timeIntervalSince1970: timestamp.doubleValue / 1000.0)
    }
    
    
  }

}
