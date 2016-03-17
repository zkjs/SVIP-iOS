//
//  ServiceIntroModel.swift
//  SVIP
//
//  Created by Qin Yejun on 3/15/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

struct ServiceIntroModel {
  let recommendTitle:String
  let recommendDesc:String
  let recommendIcon:String
  
  init(json:JSON) {
    recommendTitle = json["recommendTitle"].string ?? ""
    recommendDesc = json["recommendDesc"].string ?? ""
    recommendIcon = json["recommendIcon"].string ?? ""
  }
}