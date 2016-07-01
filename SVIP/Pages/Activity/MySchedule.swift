//
//  MySchedule.swift
//  SVIP
//
//  Created by Qin Yejun on 6/29/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ActivityStatus:Int, CustomStringConvertible {
  case Unknown = -2     // 未知
  case Cancelled = -1   // 已取消
  case Ongoing = 0      // 进行中
  
  var description: String {
    switch self {
    case .Cancelled:
      return "已取消"
    case .Ongoing:
      return "进行中"
    default:
      return "未知状态"
    }
  }
}

struct MySchedule {
  let actid:String
  let merchant:String
  let activity:String
  let startDate:String
  let endDate:String
  let statusCode: ActivityStatus
  let status: String
 
  init(json:JSON) {
    actid = json["actid"].string ?? ""
    merchant = json["shopname"].string ?? ""
    activity = json["actname"].string ?? ""
    startDate = json["startdate"].string ?? ""
    endDate = json["enddate"].string ?? ""
    status = json["actstatus"].string ?? ""
    if let s = json["actstatusCode"].int, stat = ActivityStatus(rawValue: s) {
      statusCode = stat
    } else {
      statusCode = .Unknown
    }
  }
}