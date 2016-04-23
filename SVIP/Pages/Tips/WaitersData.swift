//
//  WaitersData.swift
//  SVIP
//
//  Created by Qin Yejun on 4/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Waiter {
  let userid:String
  let name:String
  let avatar:String
  
  init(json:JSON) {
    //locid = json["locid"].string ?? ""
    userid = json["userid"].string ?? ""
    name = json["username"].string ?? ""
    avatar = json["userimage"].string ?? ""
    //sex = json["sex"].int ?? 0
    //shopid = json["shopid"].string ?? ""
    //arrivetime = json["arrivetime"].string ?? ""
  }
  
  init(userid:String, name:String, avatar:String) {
    self.userid = userid
    self.name = name
    self.avatar = avatar
  }

}

struct Count {
  let tip:String
  let reason:String
}

class WaitersData {
  private(set) var currentIndex = 0
  
  static let sharedInstance = WaitersData()
  
  //var allWaiters = [Waiter]()
  var allWaiters = [
    Waiter(userid: "c_user_01", name: "徐伟", avatar: "uploads/users/c_8bef4a7faa55bdaa_1460950874292.jpg"),
    Waiter(userid: "c_user_01", name: "覃业俊", avatar: "uploads/users/c_87db4f52b941071b_1461228041883.jpg"),
    Waiter(userid: "c_user_01", name: "林琳", avatar: "uploads/users/c_58b7444ba221520c_1461238139584.jpg"),
    Waiter(userid: "c_user_01", name: "梁颖", avatar: "uploads/users/c_727948d0a899b53b_1460173623718.jpg")
  ]
  
  func next() -> Waiter? {
    if allWaiters.count < 1 {
      return nil
    }
    if currentIndex < allWaiters.count {
      currentIndex += 1
    } else {
      currentIndex = 1
    }
    return allWaiters[currentIndex - 1]
  }
  
  func currentWaiter() -> Waiter {
    var index = currentIndex - 1
    if currentIndex < 0 {
      index = 0
    } else if currentIndex >= allWaiters.count {
      index = allWaiters.count - 1
    }
    return allWaiters[index]
  }
  
  func fetchNearbyWaiters() {
    HttpService.sharedInstance.getNearbyWaiters { (waiters, error) in
      if let waiters = waiters {
        //self.allWaiters = waiters
      }
    }
  }
}

struct TipsCountData {
  static let tips = [
    Count(tip: "￥50", reason: "超预期"),
    Count(tip: "￥100", reason: "态度好"),
    Count(tip: "￥?", reason: "质量好"),
    Count(tip: "￥10", reason: "说不清"),
    Count(tip: "￥5", reason: "一种感觉"),
    Count(tip: "￥20", reason: "喜欢给"),
  ]
}