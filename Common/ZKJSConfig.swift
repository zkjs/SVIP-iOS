//
//  ZKJSConfig.swift
//  SVIP
//
//  Created by Qin Yejun on 3/12/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

let KNOTIFICATION_LOGINCHANGE = "loginStateChange"
let KNOTIFICATION_LOGOUTCHANGE = "logoutStateChange"
let APP_GLOBAL_TINT_COLOR = UIColor(hex: "#ffc56e")

//TODO: api调试完成后在,在根据 build config 配置不同环境url
struct ZKJSConfig {
  static let sharedInstance = ZKJSConfig()
  
  #if DEBUG
  
  //// 测试环境
  
  // 新API服务器
  let BaseURL = "http://p.zkjinshi.com"
  // 图片服务器
  let BaseImageURL = "http://cdn.zkjinshi.com"
  // 云巴
  let YunBaAppKey = "56f0e58a4407a3cd028ad5de"
  // 友盟
  let UMAppKey = "55c31431e0f55a65c1002597"
  let UMURL = ""
  
  #elseif PRE_RELEASE
  
  //// 预上线
  
  // 新API服务器
  let BaseURL = "http://p.zkjinshi.com/belta"
  // 图片服务器
  let BaseImageURL = "http://svip02.oss-cn-shenzhen.aliyuncs.com/"
  // 云巴
  let YunBaAppKey = "56f0e58a4407a3cd028ad5de"
  // 友盟
  let UMAppKey = "55c31431e0f55a65c1002597"
  let UMURL = ""
  
  #else
  
  //// 生产环境
  
  // 新API服务器
  let BaseURL = "http://p.zkjinshi.com"
  // 图片服务器
  let BaseImageURL = "http://cdn.zkjinshi.com"
  // 云巴
  let YunBaAppKey = "56f0e58a4407a3cd028ad5de"
  // 友盟
  let UMAppKey = "55c31431e0f55a65c1002597"
  let UMURL = ""
  
  #endif
  
  
}