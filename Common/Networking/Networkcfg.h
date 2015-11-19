//
//  Networkcfg.h
//  BeaconMall
//
//  Created by dai.fengyi on 15/5/12.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

#ifndef BeaconMall_Networkcfg_h
#define BeaconMall_Networkcfg_h

#define kDefaultNetworkTimeout      5
#define kHeartBeatInterval          60
#define kBufferLength               1024 * 400
#define kPacketHeaderLength         4
//#define kBaseURL @"http://172.21.7.54/"  // HTTP内网服务器地址
//#define kBaseURL @"http://api.zkjinshi.com/"  // HTTP外网服务器地址
#define kBaseURL @"http://tap.zkjinshi.com/" // HTTP服务器测试地址
// TCP内网服务器
//#define WEBSOCKET_PREFIX @"ws"
//#define HOST @"192.168.1.6"
// TCP外网服务器
//#define HOST @"im.zkjinshi.cn"
#define kChatBaseURL @"http://mmm.zkjinshi.com:9090/" // 记录服务器
#define HOST @"im.zkjinshi.com"
#define WEBSOCKET_PREFIX @"wss"
#define PORT @"6666"
#endif
