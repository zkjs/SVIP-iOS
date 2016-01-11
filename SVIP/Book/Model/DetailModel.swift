//
//  DetailModel.swift
//  SVIP
//
//  Created by AlexBang on 15/12/30.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class DetailModel: NSObject {
  var address: String!
  var category: String!
  var images: NSArray!
  var shopName: String!
  var telephone: String!
  var evaluation: String!
  var score: NSNumber!
  var shopid: String!
  var shopStatus:NSNumber!
  var shopdescUrl: String!
  
  override init() {
    super.init()
  }
  init(dic: NSDictionary) {
    address = dic["address"] as? String ?? ""
    shopid = dic["shopid"] as? String ?? ""
    images = dic["images"] as? NSArray ?? NSArray()
    shopName = dic["shopName"] as? String ?? ""
    category = dic["category"] as? String ?? ""
    telephone = dic["telephone"] as? String ?? ""
    evaluation = dic["evaluation"] as? String ?? ""
    score = dic["score"] as? NSNumber ?? NSNumber(double: 0.0)
    shopStatus = dic["shopStatus"] as? NSNumber ?? NSNumber(double: 0.0)
    shopdescUrl = dic["shopdescUrl"] as? String ?? ""
    
      }

}
