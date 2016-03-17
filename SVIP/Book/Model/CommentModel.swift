//
//  CommentModel.swift
//  SVIP
//
//  Created by Qin Yejun on 3/12/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

class CommentModel {
  
  let id:String
  let userid:String
  let username:String
  let score:Int
  let content:String
  let createtime:String
  
  init(json:JSON) {
    id = json["id"].string ?? ""
    userid = json["userid"].string ?? ""
    username = json["username"].string ?? ""
    score = json["score"].int ?? 0
    content = json["content"].string ?? ""
    createtime = json["createtime"].string ?? ""
  }
}