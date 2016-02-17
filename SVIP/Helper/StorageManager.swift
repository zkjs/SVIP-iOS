//
//  StorageManager.swift
//  SVIP
//
//  Created by Hanton on 7/4/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit
private let KHistoryArray = "HistoryArray.archive"
private let kBeaconRegions = "BeaconRegions.archive"
private let kLastOrder = "LastOrder.archive"
private let kShopsInfo = "Shops.archive"
private let kHomeImages = "HomeImage.archive"
private let kCachedBeaconRegions = "CachedBeaconRegions.archive"

class StorageManager: NSObject {
  
  class func sharedInstance() -> StorageManager {
    struct Singleton {
      static let instance = StorageManager()
    }
    return Singleton.instance
  }
  
  func documentDirectory() -> NSString {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
  }
  
  func saveBeaconRegions(beaconRegions: [String: [String: String]]) {
    NSKeyedArchiver.archiveRootObject(beaconRegions, toFile: documentDirectory().stringByAppendingPathComponent(kBeaconRegions))
  }
  
  func beaconRegions() -> [String: [String: String]] {
    return NSKeyedUnarchiver.unarchiveObjectWithFile(documentDirectory().stringByAppendingPathComponent(kBeaconRegions)) as! Dictionary
  }
  
  func saveHistoryArray(historyArray:[String]) {
    NSKeyedArchiver.archiveRootObject(historyArray, toFile: documentDirectory().stringByAppendingPathComponent(KHistoryArray))
  }
  
  func historyArray() -> [String] {
    if let array = NSKeyedUnarchiver.unarchiveObjectWithFile(documentDirectory().stringByAppendingPathComponent(KHistoryArray)) as? [String] {
      return array
    } else {
      return [String]()
    }
  }
  
  func lastOrder() -> BookOrder? {
    var lastOrder: BookOrder? = nil
    if let data = NSUserDefaults.standardUserDefaults().objectForKey("LastOrder") as? NSData {
      lastOrder = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? BookOrder
    }
    return lastOrder
  }
  
  func updateLastOrder(order: BookOrder?) {
    var encodedObject: NSData? = nil
    if let lastOrder = order {
      encodedObject = NSKeyedArchiver.archivedDataWithRootObject(lastOrder)
    }
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(encodedObject, forKey: "LastOrder")
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
  
  func shopsInfo() -> NSArray? {
    let path = documentDirectory().stringByAppendingPathComponent(kShopsInfo)
    let shopsInfo = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? NSArray
    return shopsInfo
  }
  
  func saveShopsInfo(shopsInfo: NSArray) {
    let path = documentDirectory().stringByAppendingPathComponent(kShopsInfo)
    NSKeyedArchiver.archiveRootObject(shopsInfo, toFile: path)
  }
  
  func shopNameWithShopID(shopID: String) -> String? {
    let predicate = NSPredicate(format: "shopid = %@", shopID)
    let shopInfo = shopsInfo()?.filteredArrayUsingPredicate(predicate).first as! NSDictionary
    return shopInfo["fullname"] as? String
  }
  
  func shopPhoneWithShopID(shopID: String) -> String? {
    let predicate = NSPredicate(format: "shopid = %@", shopID)
    let shopInfo = shopsInfo()?.filteredArrayUsingPredicate(predicate).first as! NSDictionary
    return shopInfo["phone"] as? String
  }
  
  func saveHomeImages(images: [String]) {
    let path = documentDirectory().stringByAppendingPathComponent(kHomeImages)
    NSKeyedArchiver.archiveRootObject(images, toFile: path)
  }
  
  func homeImage() -> [String]? {
    let path = documentDirectory().stringByAppendingPathComponent(kHomeImages)
    let images = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [String]
    return images
  }
  
  func cachedBeaconRegions() -> [String: Int]? {
    let path = documentDirectory().stringByAppendingPathComponent(kCachedBeaconRegions)
    let cachedBeaconRegions = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [String: Int]
    return cachedBeaconRegions
  }
  
  func saveCachedBeaconRegions(cachedBeaconRegions: [String: Int]) {
    let path = documentDirectory().stringByAppendingPathComponent(kCachedBeaconRegions)
    NSKeyedArchiver.archiveRootObject(cachedBeaconRegions, toFile: path)
  }
  
}
