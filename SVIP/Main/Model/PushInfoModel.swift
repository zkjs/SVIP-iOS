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
  var title: String!
  var orderNo: String!
  
  override init() {
    super.init()
  }
  init(dic: NSDictionary) {
    
    desc = dic["desc"] as? String
    iconbaseurl = dic["iconbaseurl"] as? String
    iconfilename = dic["iconfilename"] as? String
    shopid = dic["shopid"] as? String
    title = dic["title"] as? String
    orderNo = dic["orderNo"] as? String
  }
}
