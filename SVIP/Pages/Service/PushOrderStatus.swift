//
//  PushOrderStatus.swift
//  SVIP
//
//  Created by Qin Yejun on 6/25/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

class PushOrderStatus: NSObject {
  var taskid:String = ""          // 呼叫任务id
  var createtime:String = ""      // 任务完成时间
  var srvname:String = ""         // 服务名称
  var waiterid:String = ""        // 服务员userid
  var waitername:String = ""      // 服务员姓名
  var waiterimage:String = ""     // 服务员头像
  var status:String = ""          // 任务状态
  var statuscode:Int = 0          // 任务状态码
  var operationseq:Int = 0        // 操作序列号
  
  override init() {
    super.init()
  }
  
  init(dict:NSDictionary) {
    taskid = dict["taskid"] as? String ?? ""
    createtime = dict["createtime"] as? String ?? ""
    srvname = dict["srvname"] as? String ?? ""
    waiterid = dict["waiterid"] as? String ?? ""
    waitername = dict["waitername"] as? String ?? ""
    waiterimage = dict["waiterimage"] as? String ?? ""
    status = dict["status"] as? String ?? ""
    statuscode = dict["statuscode"] as? Int ?? 0
    operationseq = dict["operationseq"] as? Int ?? 0
  }
}