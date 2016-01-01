//
//  OrderDetailModel.swift
//  SVIP
//
//  Created by AlexBang on 15/12/29.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderDetailModel: NSObject {
  var orderno: String!
  var shopid: String!
  var userid: String!
  var saleid: String!
  var shopname: String!
  var roomno: String!
  var roomcount: NSNumber!
  var roomtype: String!
  var paytype: NSNumber!
  var roomprice: double_t!
  var orderedby: String!
  var telephone: String!
  var arrivaldate: NSDate!
  var doublebreakfeast: NSNumber!
  var nosmoking: NSNumber!
  var company: String!
  var isinvoice: NSNumber!
  var remark: String!
  
  override init() {
    super.init()
  }
  
  init(dic: NSDictionary) {
    orderno = dic["orderno"] as? String ?? ""
    shopid = dic["shopid"] as? String ?? ""
    userid = dic["userid"] as? String ?? ""
    shopname = dic["shopname"] as? String ?? ""
    roomno = dic["roomno"] as? String ?? ""
    roomcount = dic["roomcount"] as? NSNumber ?? NSNumber(double: 0.0)
    roomtype = dic["roomtype"] as? String ?? ""
    roomprice = dic["roomprice"] as? double_t ??  double_t(0.0)
    paytype = dic["paytype"] as? NSNumber ?? NSNumber(double: 0.0)
    orderedby = dic["orderedby"] as? String ?? ""
    telephone = dic["telephone"] as? String ?? ""
    telephone = dic["telephone"] as? String ?? ""
    arrivaldate = dic["arrivaldate"] as? NSDate ?? NSDate()
    doublebreakfeast = dic["doublebreakfeast"] as? NSNumber ?? NSNumber(double: 0.0)
    nosmoking = dic["nosmoking"] as? NSNumber ?? NSNumber(double: 0.0)
    isinvoice = dic["isinvoice"] as? NSNumber ?? NSNumber(double: 0.0)
    company = dic["company"] as? String ?? ""
    remark = dic["remark"] as? String ?? ""
  }

}
