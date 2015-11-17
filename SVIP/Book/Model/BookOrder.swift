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
  nologin 免前台状态
*/
  var shopid: NSNumber!
  var room_typeid: String!
  var guest: String!
  var guesttel: String!
  var rooms: NSNumber!
  var room_type: String!
  var room_rate: NSNumber!
  var arrival_date: String!
  var departure_date: String!
  var dayInt: String!
  var phone: NSNumber!
  var userid:String!
  var star:String!
  var map_longitude: double_t!
  var map_latitude: double_t!
  //for alipay
  var reservation_no: String!

  // Hanton
  var created: String!
  var status: NSNumber!
  var remark: String!
  var fullname: String!
  var nologin: NSNumber!
  var room_image: UIImage!
  var room_image_URL: String!
  
  override var description: String {
    var output = ""
    
    output += "shopid: \(shopid)\n"
    output += "fullname: \(fullname)\n"
    output += "room_typeid: \(room_typeid)\n"
    output += "guest: \(guest)\n"
    output += "guesttel: \(guesttel)\n"
    output += "rooms: \(rooms)\n"
    output += "room_type: \(room_type)\n"
    output += "room_rate: \(room_rate)\n"
    output += "arrival_date: \(arrival_date)\n"
    output += "departure_date: \(departure_date)\n"
    output += "dayInt: \(dayInt)\n"
    output += "reservation_no: \(reservation_no)\n"
    output += "created: \(created)\n"
    output += "status: \(status)\n"
    output += "remark: \(remark)\n"
    output += "nologin: \(nologin)\n"
    output += "room_image_URL: \(room_image_URL)\n"
    output += "userid: \(userid)\n"
    output += "map_longitude: \(map_longitude)\n"
    output += "map_latitude: \(map_latitude)\n"
    return output
  }
  
  override init() {}
  
  init(dictionary: NSDictionary) {
   
    arrival_date = dictionary["arrival_date"] as? String
    created = dictionary["created"] as? String
    departure_date = dictionary["departure_date"] as? String
    phone = dictionary["phone"] as? NSNumber 
    guest = dictionary["guest"] as? String
    guesttel = dictionary["guesttel"] as? String
    remark = dictionary["remark"] as? String ?? ""
    reservation_no = dictionary["reservation_no"] as? String
    room_rate = dictionary["room_rate"] as? NSNumber
    room_type = dictionary["room_type"] as? String
    room_typeid = dictionary["room_typeid"] as? String
    rooms = dictionary["rooms"] as? NSNumber
    shopid = dictionary["shopid"] as? NSNumber
    fullname = dictionary["fullname"] as? String
    status = dictionary["status"] as? NSNumber
    nologin = dictionary["nologin"] as? NSNumber
    userid = dictionary["userid"] as? String
    map_longitude = dictionary["map_longitude"] as? double_t
    map_latitude = dictionary["map_latitude"] as? double_t
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    var startDate: NSDate?
    var endDate: NSDate?
    if arrival_date != nil {
      startDate = dateFormatter.dateFromString(arrival_date)
    }
    if departure_date != nil {
      endDate = dateFormatter.dateFromString(departure_date)
    }
    if startDate != nil && endDate != nil {
      dayInt = String(NSDate.daysFromDate(startDate!, toDate: endDate!))
    }
    room_image_URL = dictionary["room_image_URL"] as? String ?? ""
  }
  
  init (coder aDecoder: NSCoder!) {
    
    shopid = aDecoder.decodeObjectForKey("shopid") as! NSNumber
    fullname = aDecoder.decodeObjectForKey("fullname") as! String
    room_typeid = aDecoder.decodeObjectForKey("room_typeid") as? String ?? ""
    guest = aDecoder.decodeObjectForKey("guest") as? String ?? ""
    guesttel = aDecoder.decodeObjectForKey("guesttel") as? String ?? ""
    rooms = aDecoder.decodeObjectForKey("rooms") as! NSNumber
    room_type = aDecoder.decodeObjectForKey("room_type") as! String
    room_rate = aDecoder.decodeObjectForKey("room_rate") as! NSNumber
    arrival_date = aDecoder.decodeObjectForKey("arrival_date") as! String
    departure_date = aDecoder.decodeObjectForKey("departure_date") as! String
    dayInt = aDecoder.decodeObjectForKey("dayInt") as! String
    phone = aDecoder.decodeObjectForKey("phone") as! NSNumber
    reservation_no = aDecoder.decodeObjectForKey("reservation_no") as! String
    created = aDecoder.decodeObjectForKey("created") as! String
    status = aDecoder.decodeObjectForKey("status") as! NSNumber
    remark = aDecoder.decodeObjectForKey("remark") as! String
    nologin = aDecoder.decodeObjectForKey("nologin") as! NSNumber
    room_image_URL = aDecoder.decodeObjectForKey("room_image_URL") as! String
    map_longitude = aDecoder.decodeObjectForKey("map_longitude") as! double_t
    map_latitude = aDecoder.decodeObjectForKey("map_latitude") as! double_t
  }
  
  func encodeWithCoder(aCoder: NSCoder!) {
    
    aCoder.encodeObject(shopid, forKey:"shopid")
    aCoder.encodeObject(fullname, forKey:"fullname")
    aCoder.encodeObject(room_typeid, forKey:"room_typeid")
    aCoder.encodeObject(guest, forKey:"guest")
    aCoder.encodeObject(guesttel, forKey:"guesttel")
    aCoder.encodeObject(rooms, forKey:"rooms")
    aCoder.encodeObject(room_type, forKey:"room_type")
    aCoder.encodeObject(room_rate, forKey:"room_rate")
    aCoder.encodeObject(arrival_date, forKey:"arrival_date")
    aCoder.encodeObject(departure_date, forKey:"departure_date")
    aCoder.encodeObject(dayInt, forKey:"dayInt")
    aCoder.encodeObject(phone, forKey:"phone")
    aCoder.encodeObject(reservation_no, forKey:"reservation_no")
    aCoder.encodeObject(created, forKey:"created")
    aCoder.encodeObject(status, forKey:"status")
    aCoder.encodeObject(remark, forKey:"remark")
    aCoder.encodeObject(nologin, forKey:"nologin")
    aCoder.encodeObject(room_image_URL, forKey:"room_image_URL")
    aCoder.encodeObject(map_latitude,forKey: "map_latitude")
    aCoder.encodeObject(map_longitude,forKey: "map_longitude")
  }
  
}
