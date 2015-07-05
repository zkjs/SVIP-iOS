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
  
}
