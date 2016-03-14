//
//  ZKJSConfig.swift
//  SVIP
//
//  Created by Qin Yejun on 3/12/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

//TODO: api调试完成后在,在根据 build config 配置不同环境url
struct ZKJSConfig {
  static let sharedInstance = ZKJSConfig()
  
  #if DEBUG
  
  //// 测试环境
  
  // 新API服务器
  let BaseURL = "http://p.zkjinshi.com/test"
  // 图片服务器
  let BaseImageURL = "http://for-testea01cc11-44f5-431f-a393-a6595c09410d.oss-cn-shenzhen.aliyuncs.com/"
  // 环信
  let EaseMobAppKey = "zkjs#svip"
  
  #elseif PRE_RELEASE
  
  //// 预上线
  
  // 新API服务器
  let BaseURL = "http://rap.zkjinshi.com/"
  // 图片服务器
  let BaseImageURL = "http://svip02.oss-cn-shenzhen.aliyuncs.com/"
  // 环信
  let EaseMobAppKey = "zkjs#sid"
  
  #else
  
  //// 生产环境
  
  // 新API服务器
  let BaseURL = "http://api.zkjinshi.com/"
  // 图片服务器
  let BaseImageURL = "http://svip02.oss-cn-shenzhen.aliyuncs.com/"
  // 环信
  let EaseMobAppKey = "zkjs#prosvip"
  
  #endif
  
  
}