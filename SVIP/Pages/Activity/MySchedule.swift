//
//  MySchedule.swift
//  SVIP
//
//  Created by Qin Yejun on 6/29/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MySchedule {
  let merchant:String
  let activity:String
  let date:String
  let time:String
 
  init(json:JSON) {
    merchant = json["merchant"].string ?? ""
    activity = json["activity"].string ?? ""
    date = json["date"].string ?? ""
    time = json["time"].string ?? ""
  }
}