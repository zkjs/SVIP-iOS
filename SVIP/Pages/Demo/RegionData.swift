//
//  DemoData.swift
//  SVIP
//
//  Created by Qin Yejun on 5/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class  RegionData {
  static let sharedInstance = RegionData()
  private init() { }
  
  var latestRegion: Region?
  var latestTime = NSDate()
  
  lazy var allRegions:[Region]? = {
    if let path = NSBundle.mainBundle().pathForResource("demo", ofType: "json") {
      if let data = try? NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe) {
        if let jsonArr = JSON(data: data).array {
          var result = [Region]()
          for j in jsonArr {
            result.append(Region(json: j))
          }
          return result
        }
      }
    }
    return nil
  }()
  
  func RegionWithBeacon(beacon:CLBeacon) -> Region? {
    return allRegions?.filter{ $0.uuid.uppercaseString == beacon.proximityUUID.UUIDString.uppercaseString
                            && $0.major == beacon.major.integerValue }.first
  }
}