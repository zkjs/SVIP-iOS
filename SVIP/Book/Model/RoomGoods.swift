//
//  RoomGoods.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/3.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit
/*
"goodsid": "1",
"name": "\u8c6a\u534e\u53cc\u4eba\u5e8a",
"unit": "\u5957",
"goods_brief": "\u8c6a\u534e\u53cc\u4eba\u623f\u7684\u7b80\u4ecb",
"goods_desc": "\u8c6a\u534e\u53cc\u4eba\u623f\u8be6\u7ec6\u4ecb\u7ecd",
"cat_id": "2",
"isshow": "0",
"sortorder": "0",
"goods_sn": "hh001",
"keywords": "\u53cc\u4eba\u5e8a,\u9152\u5e97\u5957\u623f",
"brand_id": null,
"goods_thumb": null,
"goods_img": "uploads\/goods\/img\/1.jpg",
"original_img": null,
"is_best": "0",
"is_new": "0",
"is_hot": "0",
"seller_note": null,
"is_on_sale": "0",
"is_alone_sale": "0",
"give_integral": null,
"is_real": "0",
"market_price": "499.00",
"shop_price": "368.00",
"promote_price": "299.00",
"promote_start_date": "2015-06-01 15:18:44",
"promote_end_date": "2015-06-30 15:18:47",
"created": "2015-06-03 15:18:40",
"modified": "2015-06-03 13:58:54",
"extension_code": null,
"shopid": "120",
"cat_name": "\u8c6a\u534e\u53cc\u5e8a"
*/
class RoomGoods: NSObject {
  var goodsid: String?
  var name: String?
  var unit: String?
  var goods_brief: String?
  var goods_desc: String?
  var cat_id: String?
  var keywords: String?
  var goods_img: String?
  var market_price: String?
//  var <#string#>: String
//  var <#string#>: String
//  var <#string#>: String
//  var <#string#>: String
  var cat_name: String?

  init(dic: NSDictionary?) {
    if dic != nil{
      goodsid = dic!["goodsid"] as? String
      name = dic!["name"] as? String
      unit = dic!["unit"] as? String
      goods_brief = dic!["goods_brief"] as? String
      goods_desc = dic!["goods_desc"] as? String
      cat_id = dic!["cat_id"] as? String
      keywords = dic!["keywords"] as? String
      goods_img = dic!["goods_img"] as? String
      market_price = dic!["market_price"] as? String
    }
  }
}
