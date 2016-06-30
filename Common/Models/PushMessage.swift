//
//  PushMessage.swift
//  
//
//  Created by Qin Yejun on 4/27/16.
//
//

import Foundation
import CoreData
import SwiftyJSON

class PushMessage: NSManagedObject {
  static let MAX_CACHE_COUNT = 20
  
  static func createFromDict(dict: NSDictionary) -> PushMessage? {
    guard let message = PushMessage.create() as? PushMessage else {
      return nil
    }
    
    message.title = dict["title"] as? String ?? ""
    message.locid = dict["locid"] as? String ?? ""
    message.alert = dict["alert"] as? String ?? ""
    message.shopid = dict["shopid"] as? String ?? ""
    message.content = dict["content"] as? String ?? ""
    message.imgUrl = dict["img_url"] as? String ?? ""
    message.linkTitle = dict["button"] as? String ?? ""
    message.link = dict["button_url"] as? String ?? ""
    message.timestamp = NSDate()
    message.userid = TokenPayload.sharedInstance.userID ?? ""
    message.read = 0
    
    if let actid = dict["actid"] as? String where !actid.isEmpty {
      message.actid = actid
      message.title = dict["actname"] as? String ?? ""
      message.content = dict["actcontent"] as? String ?? ""
      message.link = dict["acturl"] as? String ?? ""
      message.imgUrl = dict["actimage"] as? String ?? ""
      message.startdate = dict["startdate"] as? String ?? ""
      message.enddate = dict["enddate"] as? String ?? ""
      message.maxtake = dict["maxtake"] as? Int ?? 0
    }
    
    return message
  }
  
  static func createFromJson(json: JSON) -> PushMessage? {
    guard let message = PushMessage.create() as? PushMessage else {
      return nil
    }
    
    message.title = json["title"].string ?? ""
    message.locid = json["locid"].string ?? ""
    message.alert = json["alert"].string ?? ""
    message.shopid = json["shopid"].string ?? ""
    message.content = json["content"].string ?? ""
    message.imgUrl = json["img_url"].string ?? ""
    message.linkTitle = json["button"].string ?? ""
    message.link = json["button_url"].string ?? ""
    message.timestamp = NSDate()
    message.userid = TokenPayload.sharedInstance.userID ?? ""
    message.read = 0
    
    if let actid = json["actid"].string where !actid.isEmpty {
      message.actid = actid
      message.title = json["actname"].string ?? ""
      message.content = json["actcontent"].string ?? ""
      message.link = json["acturl"].string ?? ""
      message.imgUrl = json["actimage"].string ?? ""
      message.startdate = json["startdate"].string ?? ""
      message.enddate = json["enddate"].string ?? ""
      message.maxtake = json["maxtake"].int ?? 0
    }
    
    return message
  }
  
  static func cancelActivity(actid:String) {
    if let msgs = PushMessage.query("actid == '\(actid)'") as? [PushMessage] {
      for m in msgs {
        m.remove()
      }
      saveAllChanges()
    }
  }
  
  static func updateActivityWithDict(dict: NSDictionary) -> PushMessage? {
    guard let actid = dict["actid"] as? String where !actid.isEmpty else {
      return nil
    }
    guard let msgs = PushMessage.query("actid == '\(actid)'") as? [PushMessage] else {
      return createFromDict(dict)
    }

    for m in msgs {
      m.linkTitle = "查看活动详情"
      m.actid = actid
      m.title = dict["actname"] as? String ?? ""
      m.alert = dict["alert"] as? String ?? ""
      m.content = dict["actcontent"] as? String ?? ""
      m.link = dict["acturl"] as? String ?? ""
      m.imgUrl = dict["actimage"] as? String ?? ""
      m.startdate = dict["startdate"] as? String ?? ""
      m.enddate = dict["enddate"] as? String ?? ""
      m.maxtake = dict["maxtake"] as? Int ?? 0
    }
    saveAllChanges()
    
    return msgs.first
  }

}
