//
//  ServicerModel.swift
//  SVIP
//
//  Created by AlexBang on 15/11/23.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class ServicerModel: NSObject {
  var name: String!
  var phone: NSNumber!
  var salesid: String!
  init(dic:[String:AnyObject]) {
    name = dic["name"] as? String
    phone = dic["phone"] as? NSNumber
    salesid = dic["salesid"] as? String
  }
}
