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
*/
  var userid: String!
  var token: String!
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
  var orderno: String!

}
