//
//  HttpService+Others.swift
//  SVIP
//
//  Created by Qin Yejun on 3/15/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension HttpService {
  
  func checkNewVersion(completionHandler: (isForceUpgrade:Bool,hasNewVersion:Bool)->Void ) {
    let bundleVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? "1.0"

    let urlString = ResourcePath.CheckVersion(version: bundleVersion).description.fullUrl
    
    get(urlString, parameters: nil,tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
      } else {
        if let data = json?["data"] {
          guard let isforceupgrade = data["isforceupgrade"].int, let verno = data["verno"].string else {
            return
          }
          completionHandler(isForceUpgrade: isforceupgrade == 1, hasNewVersion: verno > bundleVersion)
        }
      }
    }
    
  }
  
}