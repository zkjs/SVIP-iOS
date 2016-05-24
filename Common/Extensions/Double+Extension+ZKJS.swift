//
//  Double+Extension+ZKJS.swift
//  SVIP
//
//  Created by Qin Yejun on 3/1/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension Double {
  func format(f: String) -> String {
    return NSString(format: "%\(f)f", self) as String
  }
  
  var formattedCash:String {
    return "￥" + self.format(".2")
  }
}