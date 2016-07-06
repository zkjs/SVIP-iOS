//
//  MemberCardModel.swift
//  SVIP
//
//  Created by Qin Yejun on 7/5/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import SwiftyJSON

class MemberCard {
  let shopID:String
  let shopname:String
  let accountno:String
  let balance:Int
  var displayBalance:String {
    return "￥" + Double(Double(balance)/100.0).format(".2")
  }
  
  
  init(json:JSON) {
    shopID = json["shopid"].string ?? ""
    shopname = json["shopname"].string ?? ""
    accountno = json["accountno"].string ?? ""
    balance = json["balance"].int ?? 0
  }
}