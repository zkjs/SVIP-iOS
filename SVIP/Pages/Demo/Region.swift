//
//  Region.swift
//  SVIP
//
//  Created by Qin Yejun on 5/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Coord {
  let x: Double
  let y: Double
  
  init(json:JSON) {
    x = json["coord_x"].double ?? 0
    y = json["coord_y"].double ?? 0
  }
}

struct Region {
  let major: Int
  let minior: Int
  let uuid: String
  let locdesc: String
  let locid: Int
  let floor: Int
  let map: String
  let logo: String
  let brief: String
  let videoUrl: String
  let coord: Coord
  
  init(json:JSON) {
    major = json["major"].int ?? 0
    minior = json["minior"].int ?? 0
    uuid = json["uuid"].string ?? ""
    locdesc = json["locdesc"].string ?? ""
    locid = json["locid"].int ?? 0
    floor = json["floor"].int ?? 0
    map = json["map"].string ?? ""
    logo = json["logo"].string ?? ""
    brief = json["brief"].string ?? ""
    videoUrl = json["video_url"].string ?? ""
    coord = Coord(json: json)
  }
}