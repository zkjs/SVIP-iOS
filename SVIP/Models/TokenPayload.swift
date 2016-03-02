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
    guard let data = self.token.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
      return nil
    }
    return JSON(data: data)
  }
  
  init(tokenPayload:String){
    self.token = tokenPayload
  }
  
  init(tokenFullString:String) {
    let arr = tokenFullString.characters.split { $0 == "." }.map(String.init)
    self.token = arr.count > 1 ? arr[1] : ""
  }
  
}