//
//  BookOrder.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/5.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookOrder: NSObject {
  /*
  set=1是酒店订单  //set=0是普通订单
  提交必要字段
  userid= *
  token=	*
  shopid=	*
  room_typeid= * 商品goodsid
  guest =*预订人姓名
  guesttel =* 预订人电话
  rooms =* 预定房间数量
  room_type=* 房型
  room_rate=* 房价
  arrival_date=*预定日期 date类型 2015-06-07
  departure_date=*离开日期 date类型 2015-06-07
  
  room_rate=*房价在上诉商品列表获取
  
  status 订单状态
*/
  var shopid: String!
  var room_typeid: String!
  var guest: String!
  var guesttel: String!
  var rooms: String!
  var room_type: String!
  var room_rate: String!
  var arrival_date: String!
  var departure_date: String!
  
  //for alipay
  var reservation_no: String!

  // Hanton
  var created: String!
  var orderid: String!  
  var status: String!
  var remark: String!
  
  override var description: String {
    var output = ""
    output += "shopid: \(shopid)\n"
    output += "room_typeid: \(room_typeid)\n"
    output += "guest: \(guest)\n"
    output += "guesttel: \(guesttel)\n"
    output += "rooms: \(rooms)\n"
    output += "room_type: \(room_type)\n"
    output += "room_rate: \(room_rate)\n"
    output += "arrival_date: \(arrival_date)\n"
    output += "departure_date: \(departure_date)\n"
    output += "reservation_no: \(reservation_no)\n"
    output += "created: \(created)\n"
    output += "orderid: \(orderid)\n"
    output += "status: \(status)\n"
    output += "remark: \(remark)\n"
    return output
  }
  
  override init() {}
  
  init (coder aDecoder: NSCoder!) {
    shopid = aDecoder.decodeObjectForKey("shopid") as! String
    room_typeid = aDecoder.decodeObjectForKey("room_typeid") as! String
    guest = aDecoder.decodeObjectForKey("guest") as! String
    guesttel = aDecoder.decodeObjectForKey("guesttel") as! String
    rooms = aDecoder.decodeObjectForKey("rooms") as! String
    room_type = aDecoder.decodeObjectForKey("room_type") as! String
    room_rate = aDecoder.decodeObjectForKey("room_rate") as! String
    arrival_date = aDecoder.decodeObjectForKey("arrival_date") as! String
    departure_date = aDecoder.decodeObjectForKey("departure_date") as! String
    reservation_no = aDecoder.decodeObjectForKey("reservation_no") as! String
    created = aDecoder.decodeObjectForKey("created") as! String
    orderid = aDecoder.decodeObjectForKey("orderid") as! String
    status = aDecoder.decodeObjectForKey("status") as! String
    remark = aDecoder.decodeObjectForKey("remark") as! String
  }
  
  func encodeWithCoder(aCoder: NSCoder!) {
    aCoder.encodeObject(shopid, forKey:"shopid")
    aCoder.encodeObject(room_typeid, forKey:"room_typeid")
    aCoder.encodeObject(guest, forKey:"guest")
    aCoder.encodeObject(guesttel, forKey:"guesttel")
    aCoder.encodeObject(rooms, forKey:"rooms")
    aCoder.encodeObject(room_type, forKey:"room_type")
    aCoder.encodeObject(room_rate, forKey:"room_rate")
    aCoder.encodeObject(arrival_date, forKey:"arrival_date")
    aCoder.encodeObject(departure_date, forKey:"departure_date")
    aCoder.encodeObject(reservation_no, forKey:"reservation_no")
    aCoder.encodeObject(created, forKey:"created")
    aCoder.encodeObject(orderid, forKey:"orderid")
    aCoder.encodeObject(status, forKey:"status")
    aCoder.encodeObject(remark, forKey:"remark")
  }
  
}
