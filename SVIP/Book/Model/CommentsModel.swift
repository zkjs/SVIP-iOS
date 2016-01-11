//
//  CommentsModel.swift
//  SVIP
//
//  Created by AlexBang on 16/1/12.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class CommentsModel: NSObject {
  var id: NSNumber!
  var orderNo: String!
  var score: NSNumber!
  var content: String!
  var createDate: NSDate!
  var userid: String!
  var userName:String!
  override init() {
    super.init()
  }
  init(dic: NSDictionary) {
    orderNo = dic["orderNo"] as? String ?? ""
    score = dic["score"] as? NSNumber ?? NSNumber(double: 0.0)
    id = dic["id"] as? NSNumber ?? NSNumber(double: 0.0)
    userid = dic["userid"] as? String ?? ""
    content = dic["content"] as? String ?? ""
    userName = dic["userName"] as? String ?? ""
    createDate = dic["createDate"] as? NSDate ?? NSDate()
  }

}
