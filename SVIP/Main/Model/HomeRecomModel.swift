//
//  HomeRecomModel.swift
//  SVIP
//
//  Created by Qin Yejun on 3/15/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

struct HomeRecomModel {
  let desc : String
  let iconfilename: String
  let shopName: String
  let shopid: String
  let title: String
  
  init(json:JSON) {
    desc = json["desc"].string ?? ""
    iconfilename = json["iconfilename"].string ?? ""
    shopName = json["shopName"].string ?? ""
    shopid = json["shopid"].string ?? ""
    title = json["title"].string ?? ""
  }
}