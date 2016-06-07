//
//  ZKJSConfig.swift
//  SVIP
//
//  Created by Qin Yejun on 3/12/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

struct ZKJSConfig {
  static let sharedInstance = ZKJSConfig()
  
  #if DEBUG
  
  //// 测试环境
  
  // 新API服务器
  let BaseURL = "https://api.zkjinshi.com/dev"
  // 图片服务器
  let BaseImageCDNURL = "http://cdn.zkjinshi.com"
  let BaseImageURL = "http://pcd.zkjinshi.com"
  // 云巴
  let YunBaAppKey = "56f0e58a4407a3cd028ad5de"
  // 友盟
  let UMAppKey = "55c31431e0f55a65c1002597"
  let UMURL = ""
  
  let RegisterURL = "http://zkjinshi.com/shop/"
  
  #elseif PRE_RELEASE
  
  //// 预上线
  
  // 新API服务器
  let BaseURL = "http://p.zkjinshi.com/demo"
  // 图片服务器
  let BaseImageCDNURL = "http://cdn.zkjinshi.com"
  let BaseImageURL = "http://pcd.zkjinshi.com"
  // 云巴
  let YunBaAppKey = "56f0e58a4407a3cd028ad5de"
  // 友盟
  let UMAppKey = "55c31431e0f55a65c1002597"
  let UMURL = ""
  
  let RegisterURL = "http://zkjinshi.com/shop/"
  
  #else
  
  //// 生产环境
  
  // 新API服务器
  let BaseURL = "https://api.zkjinshi.com/release"
  // 图片服务器
  let BaseImageCDNURL = "http://cdn.zkjinshi.com"
  let BaseImageURL = "http://pcd.zkjinshi.com"
  // 云巴
  let YunBaAppKey = "56f0e58a4407a3cd028ad5de"
  // 友盟
  let UMAppKey = "55c31431e0f55a65c1002597"
  let UMURL = ""
  
  let RegisterURL = "http://zkjinshi.com/shop/"
  
  #endif
  
  
}