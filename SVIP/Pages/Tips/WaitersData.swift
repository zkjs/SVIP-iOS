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

struct WaitersData {
  private(set) var currentIndex = 0
  
  static let allWaiters = [
    Waiter(userid: "c_user_01", name: "徐伟", avatar: "uploads/users/c_8bef4a7faa55bdaa_1460950874292.jpg"),
    Waiter(userid: "c_user_01", name: "覃业俊", avatar: "uploads/users/c_87db4f52b941071b_1461228041883.jpg"),
    Waiter(userid: "c_user_01", name: "林琳", avatar: "uploads/users/c_58b7444ba221520c_1461238139584.jpg"),
    Waiter(userid: "c_user_01", name: "梁颖", avatar: "uploads/users/c_727948d0a899b53b_1460173623718.jpg")
  ]
  
  mutating func next() -> Waiter? {
    if WaitersData.allWaiters.count < 1 {
      return nil
    }
    if currentIndex < WaitersData.allWaiters.count {
      currentIndex += 1
    } else {
      currentIndex = 1
    }
    return WaitersData.allWaiters[currentIndex - 1]
  }
  
  func currentWaiter() -> Waiter {
    var index = currentIndex - 1
    if currentIndex < 0 {
      index = 0
    } else if currentIndex >= WaitersData.allWaiters.count {
      index = WaitersData.allWaiters.count - 1
    }
    return WaitersData.allWaiters[index]
  }
}
