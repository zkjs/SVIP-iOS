//
//  PushMessageModel.swift
//  SVIP
//
//  Created by Qin Yejun on 4/5/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

import UIKit
import SwiftyJSON

class PushMessageModel: NSObject {
  
  var title: String = ""
  var locid: String = ""
  var alert: String = ""
  var shopid: String = ""
  var content: String = ""
  
  override init() {
    super.init()
  }
  
  init(dict: NSDictionary) {
    title = dict["title"] as? String ?? ""
    locid = dict["locid"] as? String ?? ""
    alert = dict["alert"] as? String ?? ""
    shopid = dict["shopid"] as? String ?? ""
    content = dict["content"] as? String ?? ""
  }
  
  init(json:JSON) {
    title = json["title"].string ?? ""
    locid = json["locid"].string ?? ""
    alert = json["alert"].string ?? ""
    shopid = json["shopid"].string ?? ""
    content = json["content"].string ?? ""
  }
  
}