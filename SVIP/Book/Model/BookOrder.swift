//
//  BookOrder.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/5.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

// http://doc.zkjinshi.com/index.php?action=artikel&cat=17&id=67&artlang=zh&highlight=pay_status
// status 订单状态 默认0可取消订单 1已取消订单 2已确认订单 3已经完成的订单 4正在入住中 5已删除订单 int
enum OrderStatus: Int {
  case Pending = 0
  case Canceled = 1
  case Confirmed = 2
  case Finised = 3
  case Checkin = 4
  case Deleted = 5
}

// pay_status 支付状态 0未支付,1已支付,3支付一部分,4已退款, 5已挂账   int
enum PayStatus: Int {
  case Unpaid = 0
  case Paid = 1
  case PayPartial = 3
  case Refund = 4
  case OnAccount = 5
}

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
  var phone: NSNumber!
  var userid:String!
  var star:String!
  var map_longitude: double_t!
  var map_latitude: double_t!
  var reservation_no: String!
  var created: String!
  var status: NSNumber!
  var pay_status: NSNumber!
  var pay_id: NSNumber!
  var payment:NSNumber!
  var remark: String!
  var fullname: String!
  var nologin: NSNumber!
  var room_image: UIImage!
  var room_image_URL: String!
  
  var dayInt: NSNumber {
    get {
      if let arrivalDate = arrival_date, let departureDate = departure_date {
        let days = NSDate.daysFromDateString(arrivalDate, toDateString: departureDate)
        if days == 0 {
          // 当天走也算一天
          return NSNumber(integer: 1)
        }
        return NSNumber(integer: days)
      } else {
        return NSNumber(integer: 0)
      }
    }
  }
  
  var arrivalDateShortStyle: String? {
    get {
      if let arrivalDateString = arrival_date {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let arrivalDate = dateFormatter.dateFromString(arrivalDateString)!
        dateFormatter.dateFormat = "M/dd"
        return dateFormatter.stringFromDate(arrivalDate)
      } else {
        return nil
      }
    }
  }
  
  var departureDateShortStyle: String? {
    get {
      if let departureDateString = departure_date {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let departureDate = dateFormatter.dateFromString(departureDateString)!
        dateFormatter.dateFormat = "M/dd"
        return dateFormatter.stringFromDate(departureDate)
      } else {
        return nil
      }
    }
  }
  
  var roomInfo: String {
    get {
      if let arrivalDateShortStyle = arrivalDateShortStyle {
        return "\(room_type) | \(arrivalDateShortStyle) | \(dayInt)晚"
      } else {
        return "\(room_type) | \(dayInt)晚"
      }
    }
  }
  
  override var description: String {
    var output = ""
    output += "pay_status:\(pay_status)"
    output += "pay_id:\(pay_id)"
    output += "payment:\(payment)"
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
  
  override init() {
    super.init()
  }
  
  init(dictionary: [String: AnyObject]) {
    super.init()
    initWithDict(dictionary)
  }
  
  init(json: String) {
    super.init()
    if let dictionary = ZKJSTool.convertJSONStringToDictionary(json) as? [String: AnyObject] {
      initWithDict(dictionary)
    }
  }
  
  func initWithDict(dictionary: [String: AnyObject]) {
    arrival_date = dictionary["arrival_date"] as? String
    created = dictionary["created"] as? String
    departure_date = dictionary["departure_date"] as? String
    if let phone = dictionary["phone"] as? NSNumber {
      self.phone = phone
    } else if let phone = dictionary["phone"] as? String {
      self.phone = NSNumber(longLong: Int64(phone)!)
    }
    guest = dictionary["guest"] as? String
    guesttel = dictionary["guesttel"] as? String
    remark = dictionary["remark"] as? String ?? ""
    reservation_no = dictionary["reservation_no"] as? String
    if let room_rate = dictionary["room_rate"] as? NSNumber {
      self.room_rate = room_rate
    } else if let room_rate = dictionary["room_rate"] as? String {
      self.room_rate = NSNumber(double: Double(room_rate)!)
    }
    room_type = dictionary["room_type"] as? String
    room_typeid = dictionary["room_typeid"] as? String
    if let rooms = dictionary["rooms"] as? NSNumber {
      self.rooms = rooms
    } else if let rooms = dictionary["rooms"] as? String {
      self.rooms = NSNumber(integer: Int(rooms)!)
    }
    if let shopid = dictionary["shopid"] as? NSNumber {
      self.shopid = shopid
    } else if let shopid = dictionary["shopid"] as? String {
      self.shopid = NSNumber(integer: Int(shopid)!)
    }
    fullname = dictionary["fullname"] as? String
    if let status = dictionary["status"] as? NSNumber {
      self.status = status
    } else if let status = dictionary["status"] as? String {
      self.status = NSNumber(integer: Int(status)!)
    }
    if let pay_status = dictionary["pay_status"] as? NSNumber {
      self.pay_status = pay_status
    } else if let pay_status = dictionary["pay_status"] as? String {
      self.pay_status = NSNumber(integer: Int(pay_status)!)
    }
    if let payment = dictionary["payment"] as? NSNumber {
      self.payment = payment
    } else if let payment = dictionary["payment"] as? String {
      self.payment = NSNumber(integer: Int(payment)!)
    }
    if let nologin = dictionary["nologin"] as? NSNumber {
      self.nologin = nologin
    } else if let nologin = dictionary["nologin"] as? String {
      self.nologin = NSNumber(integer: Int(nologin)!)
    }
    userid = dictionary["userid"] as? String
    map_longitude = dictionary["map_longitude"] as? double_t
    map_latitude = dictionary["map_latitude"] as? double_t
    if let imageURL = dictionary["room_image_URL"] as? String {
      room_image_URL = kBaseURL + imageURL
    } else if let imageURL = dictionary["image"] as? String {
      room_image_URL = kBaseURL + imageURL
    } else {
      room_image_URL = ""
    }
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
    phone = aDecoder.decodeObjectForKey("phone") as! NSNumber
    reservation_no = aDecoder.decodeObjectForKey("reservation_no") as! String
    created = aDecoder.decodeObjectForKey("created") as! String
    status = aDecoder.decodeObjectForKey("status") as! NSNumber
    remark = aDecoder.decodeObjectForKey("remark") as! String
    nologin = aDecoder.decodeObjectForKey("nologin") as! NSNumber
    room_image_URL = aDecoder.decodeObjectForKey("room_image_URL") as! String
    map_longitude = aDecoder.decodeObjectForKey("map_longitude") as? double_t
    map_latitude = aDecoder.decodeObjectForKey("map_latitude") as? double_t
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
