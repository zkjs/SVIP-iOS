//
//  ShopDetailModel.swift
//  SVIP
//
//  Created by Qin Yejun on 3/12/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

class ShopDetailModel:Shop {
  
  let shopdesc:String
  let shopstatus:Int
  let telephone:String
  let evaluation:Int
  let score:Double
  let images:[String]
  
  override init(json:JSON) {
    shopdesc = json["shopdesc"].string ?? ""
    shopstatus = json["shopstatus"].int ?? 0
    telephone = json["telephone"].string ?? ""
    evaluation = json["evaluation"].int ?? 0
    score = json["score"].double ?? 0.0
    images = json["images"].array?.flatMap{ $0.string?.fullImageUrl } ?? []
    super.init(json: json)
  }
  
}