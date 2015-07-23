//
//  StorageManager.swift
//  SVIP
//
//  Created by Hanton on 7/4/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

private let kBeaconRegions = "kBeaconRegions.archive"
private let kLastOrder = "kLastOrder.archive"

class StorageManager: NSObject {
  
  class func sharedInstance() -> StorageManager {
    struct Singleton {
      static let instance = StorageManager()
    }
    return Singleton.instance
  }
  
  func documentDirectory() -> String {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
  }
  
  func saveBeaconRegions(beaconRegions: [String: [String: String]]) {
    NSKeyedArchiver.archiveRootObject(beaconRegions, toFile: documentDirectory().stringByAppendingPathComponent(kBeaconRegions))
  }
  
  func beaconRegions() -> [String: [String: String]] {
    return NSKeyedUnarchiver.unarchiveObjectWithFile(documentDirectory().stringByAppendingPathComponent(kBeaconRegions)) as! Dictionary
  }
  
  func lastOrder() -> BookOrder? {
    return NSKeyedUnarchiver.unarchiveObjectWithFile(documentDirectory().stringByAppendingPathComponent(kLastOrder)) as? BookOrder
  }
  
  func updateLastOrder(order: BookOrder) {
    NSKeyedArchiver.archiveRootObject(order, toFile: documentDirectory().stringByAppendingPathComponent(kLastOrder))
  }
  
  func lastBeacon() -> [String: String]? {
    return NSUserDefaults.standardUserDefaults().objectForKey("LastBeacon") as? [String: String]
  }
  
  func updateLastBeacon(beacon: [String: String]?) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(beacon, forKey: "LastBeacon")
    defaults.synchronize()
  }
  
  func lastChatMessage(shopID: String) -> [String: String]? {
    return NSUserDefaults.standardUserDefaults().objectForKey(shopID) as? [String: String]
  }
  
  func updateLastChatMessage(message: [String: String]?, shopID: String) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(message, forKey: shopID)
    defaults.synchronize()
  }
  
  func chatSession(shopID: String) -> NSString? {
    let sessionID = NSUserDefaults.standardUserDefaults().objectForKey("ChatSession\(shopID)") as? NSString
    return sessionID
  }
  
  func saveChatSession(chatSession: NSString, shopID: String) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(chatSession, forKey: "ChatSession\(shopID)")
    defaults.synchronize()
  }
  
  func shopMessageBadge() -> [String: Int]? {
    return NSUserDefaults.standardUserDefaults().objectForKey("ShopMessageBadge") as? [String: Int]
  }
  
  func updateShopMessageBadge(shopMessageBadge: [String: Int]?) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(shopMessageBadge, forKey: "ShopMessageBadge")
    defaults.synchronize()
  }
  
}
