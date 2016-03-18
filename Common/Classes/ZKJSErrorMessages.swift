//
//  ZKJSErrorMessages.swift
//  SVIP
//  HTTP 请求返还错误处理
//  Created by Qin Yejun on 3/2/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

class ZKJSErrorMessages:NSObject {
  static let sharedInstance = ZKJSErrorMessages()
  private override init() {}
  lazy var msgDict:[String:String]? = {
    var myDict: NSDictionary?
    if let path = NSBundle.mainBundle().pathForResource("errorMessages", ofType: "plist") {
      myDict = NSDictionary(contentsOfFile: path)
    }
    if let dict = myDict?["HttpErrors"] as? [String:String] {
      return dict
    } else {
      return nil
    }
  }()
  
  //// 根据key返还相应错误信息
  func errorString(key:String) -> String? {
    return msgDict?[key]
  }
  
  //// 显示错误信息给用户
  func showError(key:String) {
    if let msg = errorString(key) {
      ZKJSTool.showMsg(msg)
    }
  }
}