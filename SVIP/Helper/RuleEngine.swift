//
//  RuleEngine.swift
//  SVIP
//
//  Created by Hanton on 7/5/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

enum RuleType {
  case OutOfRegion_NoOrder
  case OutOfRegion_HasOrder_UnCheckin
  case OutOfRegion_HasOrder_Checkin
  case InRegion_NoOrder
  case InRegion_HasOrder_UnCheckin
  case InRegion_HasOrder_Checkin
}

class RuleEngine: NSObject {
  
  class func sharedInstance() -> RuleEngine {
    struct Singleton {
      static let instance = RuleEngine()
    }
    return Singleton.instance
  }
  
  func getRuleType(order: [String: String]?, beacon: [String: String]?) -> RuleType {
    if let beaconInfo = beacon {
      // 在Beacon区域
      if let orderInfo = order {
        // 有订单
        if orderInfo["status"] == "4" {
          // 已入住
          return RuleType.InRegion_HasOrder_Checkin
        } else {
          // 未入住
          return RuleType.InRegion_HasOrder_UnCheckin
        }
      } else {
        // 没有订单
        return RuleType.InRegion_NoOrder
      }
    } else {
      // 不在Beacon区域
      if let orderInfo = order {
        // 有订单
        if orderInfo["status"] == "4" {
          // 已入住
          return RuleType.OutOfRegion_HasOrder_Checkin
        } else {
          // 未入住
          return RuleType.OutOfRegion_HasOrder_UnCheckin
        }
      } else {
        // 没有订单
        return RuleType.OutOfRegion_NoOrder
      }
    }
  }
  
}
