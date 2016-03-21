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
  
  let DEMO_ACCOUNT = "18503027465"
  
  #if DEBUG
  
  //// 测试环境
  
  // 新API服务器
  let BaseURL = "http://p.zkjinshi.com/alpha"
  // 图片服务器
  let BaseImageURL = "http://for-testea01cc11-44f5-431f-a393-a6595c09410d.oss-cn-shenzhen.aliyuncs.com/"
  // 云巴
  let YunBaAppKey = "566563014407a3cd028aa72f"
  
  #elseif PRE_RELEASE
  
  //// 预上线
  
  // 新API服务器
  let BaseURL = "http://rap.zkjinshi.com/"
  // 图片服务器
  let BaseImageURL = "http://svip02.oss-cn-shenzhen.aliyuncs.com/"
  // 云巴
  let YunBaAppKey = "566563014407a3cd028aa72f"
  
  #else
  
  //// 生产环境
  
  // 新API服务器
  let BaseURL = "http://api.zkjinshi.com/"
  // 图片服务器
  let BaseImageURL = "http://svip02.oss-cn-shenzhen.aliyuncs.com/"
  // 云巴
  let YunBaAppKey = "566563014407a3cd028aa72f"
  
  #endif
  
  
}