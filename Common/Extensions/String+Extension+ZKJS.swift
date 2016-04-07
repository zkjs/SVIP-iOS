//
//  String+Extension+ZKJS.swift
//  SVIP
//
//  Created by Qin Yejun on 3/1/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension String {
  // Slower version
  func repeatString(n: Int) -> String {
    return Array(count: n, repeatedValue: self).joinWithSeparator("")
  }
  
  // Faster version
  // benchmarked with a 1000 characters and 100 repeats the fast version is approx 500 000 times faster :-)
  func `repeat`(n:Int) -> String {
    var result = self
    for _ in 1 ..< n {
      result += self
    }
    return result
  }
  
  var md5: String! {
    let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
    let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    let digestLen = Int(CC_MD5_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
    
    CC_MD5(str!, strLen, result)
    
    let hash = NSMutableString()
    for i in 0..<digestLen {
      hash.appendFormat("%02x", result[i])
    }
    
    result.dealloc(digestLen)
    
    return String(format: hash as String)
  }
  
  var trim: String {
    return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }
  
  var isEmail: Bool {
    return (self =~ "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$")
  }
  
  var isMobile: Bool {
    return (self =~ "^0?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$")
  }
  
  var fullImageUrl: String {
    return ZKJSConfig.sharedInstance.BaseImageURL.stringByTrimmingCharactersInSet(
      NSCharacterSet(charactersInString: "/")
      )  + "/" + self.stringByTrimmingCharactersInSet(
      NSCharacterSet(charactersInString: "/")
    )
  }
  
  var fullUrl:String {
    return ZKJSConfig.sharedInstance.BaseURL.stringByTrimmingCharactersInSet(
      NSCharacterSet(charactersInString: "/")
      ) + "/" + self.stringByTrimmingCharactersInSet(
      NSCharacterSet(charactersInString: "/")
    )
  }
  
}
