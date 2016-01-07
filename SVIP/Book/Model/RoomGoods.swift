//
//  RoomGoods.swift
//  SVIP
//
//  Created by Hanton on 15/7/3.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class RoomGoods: NSObject {
  var goodsid: String!
  var shopid: String!
  var room: String!
  var image: String!
  var type: String!
  var meat: String!
  var price: String!
  var logo: String?
  var fullname: String?
  
  init(dic: NSDictionary) {
    if let goodsid = dic["id"] as? NSNumber {
      self.goodsid = goodsid.stringValue
    }
    room = dic["room"] as? String ?? ""
    image = dic["imgurl"] as? String ?? ""
    type = dic["type"] as? String ?? ""
    meat = dic["meat"] as? String ?? "无早"  //避免服务器返回空值
    price = dic["price"] as? String ?? ""
  }
}
