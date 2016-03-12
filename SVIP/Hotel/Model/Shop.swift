//
//  Shop.swift
//  SVIP
//
//  Created by Qin Yejun on 3/11/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

struct Shop {
  
  let shopid:String               //商户编号
  let shoplogo:String             //商户LOGO
  let shopname:String             //商户名称
  let shoptitle:String            //标题
  let shopindustry:String         //所属行业
  let shopaddress:String          //所在地址
  let salesid:String              //用户在该商家的专属销售/客服
  let bgimgurl:String             //背景图片链接路径
  let recomm:String               //推荐语
  let link:String                 //如果是专题条目, 这里会返回链接地址
  
  init (json:JSON) {
    
    shopid = json["shopid"].string ?? ""
    shoplogo = json["shoplogo"].string ?? ""
    shopname = json["shopname"].string ?? ""
    shoptitle = json["shoptitle"].string ?? ""
    shopindustry = json["shopindustry"].string ?? ""
    shopaddress = json["shopaddress"].string ?? ""
    salesid = json["salesid"].string ?? ""
    bgimgurl = json["bgimgurl"].string ?? ""
    recomm = json["recomm"].string ?? ""
    link = json["link"].string ?? ""
  }
}