//
//  RegexHelper.swift
//  SVIP
//
//  Created by Qin Yejun on 3/1/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation


struct RegexHelper {
  let regex: NSRegularExpression?
  init(_ pattern: String) {
    var error: NSError?
    do {
      regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    } catch let error1 as NSError {
      error = error1
      regex = nil
    }
  }
  
  func match(input: String) -> Bool {
    if let matches = regex?.matchesInString(input, options: [], range: NSMakeRange(0, input.characters.count)) {
      return matches.count > 0
    } else {
      return false
    }
  }
}

infix operator =~ {
associativity none
precedence 130
}
func =~(lhs: String, rhs: String) -> Bool {
  return RegexHelper(rhs).match(lhs)
}


func delay(seconds seconds: Double, completion:()->()) {
  let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
  
  dispatch_after(popTime, dispatch_get_main_queue()) {
    completion()
  }
}