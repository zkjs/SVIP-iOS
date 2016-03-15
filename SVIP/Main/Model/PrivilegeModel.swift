//
//  PrivilegeModel.swift
//  SVIP
//
//  Created by AlexBang on 15/12/18.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class PrivilegeModel: NSObject {
  var privilegeDesc: String!
  var privilegeIcon: String!
  var privilegeName: String!
  
  override init() {
    super.init()
  }
  
  init(dic: [String: AnyObject]) {
    privilegeDesc = dic["privilegeDesc"] as? String ?? ""
    privilegeIcon = dic["privilegeIcon"] as? String ?? ""
    privilegeName = dic["privilegeName"] as? String ?? ""
  }
  
  init(json:JSON) {
    privilegeName = json["recommendTitle"].string ?? ""
    privilegeDesc = json["recommendDesc"].string ?? ""
    privilegeIcon = json["recommendIcon"].string ?? ""
  }
  
}
