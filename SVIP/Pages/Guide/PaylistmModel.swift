//
//  PaylistmModel.swift
//  SVIP
//
//  Created by AlexBang on 16/3/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit
import SwiftyJSON
class PaylistmModel: NSObject {
  var shopid: String = ""
  var shopname: String = ""
  var createtime: String = ""
  var amount: Int = 0  // 注意：单位是分
  var orderno: String = ""
  var paymentno: String = ""
  var status = FacePayOrderStatus.Unknown
  var statusdesc: String = ""
  var confirmtime: String = ""
  var displayAmount:String {
    return (Double(amount) / 100).format(".2")
  }
  override init() {
    super.init()
  }
  init(dict:NSDictionary) {
    shopid = dict["shopid"] as? String ?? ""
    shopname = dict["shopname"] as? String ?? ""
    createtime = dict["createtime"] as? String ?? ""
    amount = dict["amount"] as? Int ?? 0
    orderno = dict["orderno"] as? String ?? ""
    paymentno = dict["paymentno"] as? String ?? ""
    statusdesc = dict["statusdesc"] as? String ?? ""
    confirmtime = dict["confirmtime"] as? String ?? ""
    if let s = dict["status"] as? Int {
      status = FacePayOrderStatus(rawValue: s) ?? .Unknown
    }
  }

  init(json:JSON) {
    shopid = json["shopid"].string ?? ""
    shopname = json["shopname"].string ?? ""
    createtime = json["createtime"].string ?? ""
    amount = json["amount"].int ?? 0
    orderno = json["orderno"].string ?? ""
    paymentno = json["paymentno"].string ?? ""
    statusdesc = json["statusdesc"].string ?? ""
    confirmtime = json["confirmtime"].string ?? ""
    if let s = json["status"].int {
      status = FacePayOrderStatus(rawValue: s) ?? .Unknown
    }

  }

  
}
