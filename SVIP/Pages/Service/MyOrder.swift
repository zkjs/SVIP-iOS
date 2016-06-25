//
//  MyOrder.swift
//  SVIP
//
//  Created by Qin Yejun on 6/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import SwiftyJSON

enum OrderStatus:Int, CustomStringConvertible {
  case Unknown = 0
  case Waiting        // 未处理
  case Assigned       // 已指派 | 处理中
  case Processing     // 已就绪 | 处理中
  case Finished       // 已完成
  case Rated          // 已评价 | 已完成
  
  var description: String {
    switch self {
    case .Waiting:
      return "未处理"
    case .Assigned, .Processing:
      return "处理中"
    case .Finished, .Rated:
      return "已完成"
    default:
      return "未知状态"
    }
  }
}

struct MyOrder {
  let taskid: String
  let title: String
  let createtime: String
  let statusCode: OrderStatus
  let status: String
  
  init(json:JSON) {
    taskid = json["taskid"].string ?? ""
    title = json["srvname"].string ?? ""
    createtime = json["createtime"].string ?? ""
    status = json["status"].string ?? ""
    if let s = json["statuscode"].int, stat = OrderStatus(rawValue: s) {
      statusCode = stat
    } else {
      statusCode = .Unknown
    }
  }
}