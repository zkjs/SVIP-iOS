//
//  StorageManager.swift
//  SVIP
//
//  Created by Hanton on 7/4/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

private let kBeaconRegions = "kBeaconRegions.archive"

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
  
  func lastOrder() -> [String: String]? {
    return NSUserDefaults.standardUserDefaults().objectForKey("LastOrder") as? [String: String]
  }
  
  func updateLastOrder(order: [String: String]?) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(order, forKey: "LastOrder")
    defaults.synchronize()
  }
  
  func lastBeacon() -> [String: String]? {
    return NSUserDefaults.standardUserDefaults().objectForKey("LastBeacon") as? [String: String]
  }
  
  func updateLastBeacon(beacon: [String: String]?) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(beacon, forKey: "LastBeacon")
    defaults.synchronize()
  }
  
  func chatSession(shopID: String) -> String? {
    return NSUserDefaults.standardUserDefaults().objectForKey(shopID) as? String
  }
  
  func saveChatSession(chatSession: String, shopID: String) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(chatSession, forKey: shopID)
    defaults.synchronize()
  }
  
}
