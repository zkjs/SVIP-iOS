//
//  ShopDetailModel.swift
//  SVIP
//
//  Created by AlexBang on 16/4/7.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit
import SwiftyJSON
class ShopDetailModel: ShopmodsModel {
  let shopdesc:String
  let shopaddress:String
  let shopstatus:Int
  let telephone:String
  let evaluation:Int
  let score:Double
  let shopID:String
  let shopname:String
  let shoplogo:String
  let shopmods:[ShopmodsModel]
  
  
  override init(json:JSON) {
    shopID = json["shopid"].string ?? ""
    shopaddress = json["shopaddress"].string ?? ""
    shopname = json["shopname"].string ?? ""
    shoplogo = json["shoplogo"].string ?? ""
    shopdesc = json["shopdesc"].string ?? ""
    shopstatus = json["shopstatus"].int ?? 0
    telephone = json["telephone"].string ?? ""
    evaluation = json["evaluation"].int ?? 0
    score = json["score"].double ?? 0.0
    shopmods = json["shopmods"].array?.flatMap{ return ShopmodsModel(json: $0) } ?? []

    super.init(json: json)
  }
}
