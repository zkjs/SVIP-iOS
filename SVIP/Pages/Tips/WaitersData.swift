//
//  WaitersData.swift
//  SVIP
//
//  Created by Qin Yejun on 4/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

struct Waiter {
  let userid:String
  let name:String
  let avatar:String
}

struct Count {
  let tip:String
  let reason:String
}

struct WaitersData {
  static let allWaiters = [
    Waiter(userid: "c_user_01", name: "徐伟", avatar: "uploads/users/c_8bef4a7faa55bdaa_1460950874292.jpg"),
    Waiter(userid: "c_user_01", name: "覃业俊", avatar: "uploads/users/c_87db4f52b941071b_1461228041883.jpg"),
    Waiter(userid: "c_user_01", name: "林琳", avatar: "uploads/users/c_58b7444ba221520c_1461238139584.jpg"),
    Waiter(userid: "c_user_01", name: "梁颖", avatar: "uploads/users/c_727948d0a899b53b_1460173623718.jpg")
  ]
}

struct TipsCountData {
  static let tips = [
    Count(tip: "￥50", reason: "超预期"),
    Count(tip: "￥100", reason: "态度好"),
    Count(tip: "￥?", reason: "质量好"),
    Count(tip: "￥10", reason: "说不清"),
    Count(tip: "￥5", reason: "一种感觉"),
    Count(tip: "￥20", reason: "喜欢 给"),
  ]
}