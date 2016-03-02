//
//  TokenPayload.swift
//  SVIP
//
//  Created by Qin Yejun on 3/2/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

struct TokenPayload {
  let token:String
  let tokenPayload:String
  var userID:String? {
    return json?["sub"].string
  }
  var type:Int? {
    return json?["type"].int
  }
  var expire:Int? {
    return json?["expire"].int
  }
  var roles:[String]? {
    return json?["roles"].array?.map{$0.string}.filter{$0 != nil}.map{$0!}
  }
  
  private var json: JSON? {
    guard let data = self.tokenPayload.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
      return nil
    }
    return JSON(data: data)
  }
  
//  init(tokenPayload:String){
//    self.token = tokenPayload
//  }
  
  init(tokenFullString:String) {
    let arr = tokenFullString.characters.split { $0 == "." }.map(String.init)
    let payload = arr.count > 1 ? arr[1] : ""
    
    let rem = payload.characters.count % 4
    var ending = ""
    if rem > 0 {
      let amount = 4 - rem
      ending = String(count: amount, repeatedValue: Character("="))
    }
    let base64 = payload.stringByReplacingOccurrencesOfString("-", withString: "+", options: NSStringCompareOptions(rawValue: 0), range: nil)
      .stringByReplacingOccurrencesOfString("_", withString: "/", options: NSStringCompareOptions(rawValue: 0), range: nil) + ending
    
    let decodedData = NSData(base64EncodedString:base64, options:NSDataBase64DecodingOptions(rawValue: 0))
    let decodedString = NSString(data: decodedData!, encoding: NSUTF8StringEncoding) as! String
    
    self.tokenPayload = decodedString
    self.token = tokenFullString
  }
  
  func saveTokenPayload() {
      let userDefaults = NSUserDefaults()
      userDefaults.setObject(self.token, forKey: "tokenPayload")
      userDefaults.synchronize()
  }

  
}