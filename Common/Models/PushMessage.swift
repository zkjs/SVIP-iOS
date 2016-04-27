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
    
    return message
  }

}
