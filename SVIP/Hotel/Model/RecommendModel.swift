//
//  RecommendModel.swift
//  SVIP
//
//  Created by AlexBang on 15/12/17.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class RecommendModel: NSObject {
  var link_url: String!
  var recommend_content: String!
  var recommend_logo:String!
  var recommend_title: String!
  var shop_bgimgurl: String!
  var shopid: String!
  
  
  override init() {
    super.init()
  }
  
  init(dic: NSDictionary) {
    
    link_url = dic["link_url"] as! String
    recommend_content = dic["recommend_content"] as! String
    recommend_logo = dic["recommend_logo"] as? String
    recommend_title = dic["recommend_title"] as? String
    shop_bgimgurl = dic["shop_bgimgurl"] as? String
    shopid = dic["shopid"] as? String
    
  }

}
