//
//  OrderDetailModel.swift
//  SVIP
//
//  Created by AlexBang on 15/12/29.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderDetailModel: NSObject {
  var arrivaldate: String!
  var company: String!
  var doublebreakfeast: NSNumber!
  var imgurl: String!
  var isinvoice: NSNumber!
  var leavedate: String!
  var nosmoking: NSNumber!
  var orderedby: String!
  var orderno: String!
  var orderstatus: String!
  var paytype: NSNumber!
  var personcount: String!
  var productid: String!
  var remark: String!
  var roomcount: NSNumber!
  var roomno: String!
  var roomprice: double_t!
  var roomtype: String!
  var saleid: String!
   var shopid: String!
   var shopname: String!
   var telephone: String!
   var userid: String!
   var username: String!
  var dayInt: NSNumber {
    get {
      if let arrivalDate = arrivaldate, let departureDate = leavedate {
        let days = NSDate.daysFromDateString(arrivalDate, toDateString: departureDate)
        if days == 0 {
          // 当天走也算一天
          return NSNumber(integer: 1)
        }
        return NSNumber(integer: days)
      } else {
        return NSNumber(integer: 0)
      }
    }
  }
  override init() {
    super.init()
  }
  
  init(dic: NSDictionary) {
    arrivaldate = dic["arrivaldate"] as? String ?? ""
    company = dic["company"] as? String ?? ""
    doublebreakfeast = dic["doublebreakfeast"] as? NSNumber ?? NSNumber(double: 0.0)
    imgurl = dic["imgurl"] as? String ?? ""
    isinvoice = dic["isinvoice"] as? NSNumber ?? NSNumber(double: 0.0)
    leavedate = dic["leavedate"] as? String ?? ""
    nosmoking = dic["nosmoking"] as? NSNumber ?? NSNumber(double: 0.0)
    orderedby = dic["orderedby"] as? String ?? ""
    orderno = dic["orderno"] as? String ?? ""
    orderstatus = dic["orderstatus"] as? String ?? ""
    paytype = dic["paytype"] as? NSNumber ?? NSNumber(double: 0.0)
    personcount = dic["personcount"] as? String ?? ""
    remark = dic["remark"] as? String ?? ""
    roomcount = dic["roomcount"] as? NSNumber ?? NSNumber(double: 0.0)
    roomno = dic["roomno"] as? String ?? ""
    roomprice = dic["roomprice"] as? double_t ?? double_t(0.0)
    roomtype = dic["roomtype"] as? String ?? ""
    saleid = dic["saleid"] as? String ?? ""
    shopid = dic["shopid"] as? String ?? ""
    shopname = dic["shopname"] as? String ?? ""
    telephone = dic["telephone"] as? String ?? ""
    userid = dic["userid"] as? String ?? ""
    username = dic["username"] as? String ?? ""
  }

}
