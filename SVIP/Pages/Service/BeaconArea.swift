//
//  BeaconArea.swift
//  SVIP
//
//  Created by Qin Yejun on 6/23/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BeaconArea {
  var locid:String = ""
  var area:String = ""
  
  init(json:JSON) {
    locid  = json["locid"].string ?? ""
    area = json["area"].string ?? ""
  }
  
  init(locid:String, area:String) {
    self.locid = locid
    self.area = area
  }
}
