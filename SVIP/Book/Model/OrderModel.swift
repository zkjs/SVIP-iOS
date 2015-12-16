//
//  OrderModel.swift
//  SVIP
//
//  Created by AlexBang on 15/11/9.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class OrderModel: NSObject {
  var reservation_no: String!
  var created: String!
  var room_rate: NSNumber!
  var fullname: String!
  var userid: String!
  var shopid: NSNumber!
  var arrival_date: String!
  var departure_date: String!
  var room_type: String!
  var room_typeid: NSNumber?
  var guest: String!
  var guesttel: NSNumber!
  var nologin: NSNumber!
  var rooms: NSNumber!
  var status: NSNumber!
  var pay_status: NSNumber!
  var score: NSNumber!
  
  override init() {
    super.init()
  }
  init(dic: NSDictionary) {
    reservation_no = dic["reservation_no"] as? String ?? ""
    created = dic["created"] as? String ?? ""
    room_rate = dic["room_rate"] as? NSNumber ?? NSNumber(double: 0.0)
    fullname = dic["fullname"] as? String ?? ""
    userid = dic["userid"] as? String ?? ""
    shopid = dic["shopid"] as? NSNumber ?? NSNumber(double: 0.0)
    arrival_date = dic["arrival_date"] as? String ?? ""
    room_type = dic["room_type"] as? String ?? ""
    departure_date = dic["departure_date"] as? String ?? ""
    room_typeid = dic["room_typeid"] as? NSNumber ?? NSNumber(double: 0.0)
    guest = dic["guest"] as? String ?? ""
    guesttel = dic["guesttel"] as? NSNumber ?? NSNumber(double: 0.0)
    nologin = dic["nologin"] as? NSNumber ?? NSNumber(double: 0.0)
    rooms = dic["rooms"] as? NSNumber ?? NSNumber(double: 0.0)
    status = dic["status"] as? NSNumber ?? NSNumber(double: 0.0)
    pay_status = dic["pay_status"] as? NSNumber ?? NSNumber(double: 0.0)
    score = dic["score"] as? NSNumber ?? NSNumber(double: 0.0)
  }

}
