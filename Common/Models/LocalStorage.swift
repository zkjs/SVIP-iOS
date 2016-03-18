//
//  LocalStorage.swift
//  SVIP
//
//  Created by Qin Yejun on 3/11/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

struct LocalStorage {
  
  static func objectForKey(key:String) -> AnyObject? {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    return userDefaults.objectForKey(key)
  }
  
  static func setObject(obj:AnyObject?, forKey key:String) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(obj, forKey: key)
    userDefaults.synchronize()
  }
  
}