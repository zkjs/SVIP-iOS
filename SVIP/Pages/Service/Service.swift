//
//  ServiceLoc.swift
//  SVIP
//
//  Created by Qin Yejun on 6/23/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ServiceLoc {
  var locid:String = ""
  var locdesc:String = ""
  var categories:[SerivceCategory] = [SerivceCategory]()
  
  init(json:JSON) {
    locid = json["locid"].string ?? ""
    locdesc = json["locdesc"].string ?? ""
    if let tags = json["services"].array where tags.count > 0 {
      var s = [SerivceCategory]()
      for t in tags {
        s.append(SerivceCategory(json: t))
      }
      categories = s
    } else {
      categories = [SerivceCategory]()
    }
  }
}

struct SerivceCategory {
  let id:Int
  let name:String
  let services:[ServiceTag]
  var collapse = false
  
  init(json:JSON) {
    id = json["firstSrvTagId"].int ?? 0
    name = json["firstSrvTagName"].string ?? ""
    if let tags = json["secondSrvTag"].array where tags.count > 0 {
      var s = [ServiceTag]()
      for t in tags {
        s.append(ServiceTag(json: t))
      }
      services = s
    } else {
      services = [ServiceTag]()
    }
  }
}

struct ServiceTag {
  let id:Int
  let name:String
  var desc:String
  
  init(json:JSON) {
    id = json["secondSrvTagId"].int ?? 0
    name = json["secondSrvTagName"].string ?? ""
    desc = json["secondSrvTagDesc"].string ?? ""
  }
}