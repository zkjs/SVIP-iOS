//
//  Configure.h
//  SuperService
//
//  Created by Hanton on 1/13/16.
//  Copyright © 2016 ZKJS. All rights reserved.
//

#ifndef Configure_h
#define Configure_h

// 图片服务器
#define kImageURL @"http://svip02.oss-cn-shenzhen.aliyuncs.com"

// 测试
//#define kBaseURL @"http://tst.zkjinshi.com/"  // PHP服务器
//#define kJavaBaseURL @"http://test.zkjinshi.com/japi/"  // Java服务器
#define kEaseMobAppKey @"zkjs#svip"  // 环信


// 预上线
//#define kBaseURL @"http://rap.zkjinshi.com/" // PHP服务器
//#define kJavaBaseURL @"http://p.zkjinshi.com/japi/"  // Java服务器
//#define kEaseMobAppKey @"zkjs#sid"  // 环信

// 正式
#define kBaseURL @"http://api.zkjinshi.com/" // PHP服务器
#define kJavaBaseURL @"http://mmm.zkjinshi.com/"  // Java服务器
//#define kEaseMobAppKey @"zkjs#prosvip"  // 环信

//位置
#define kBaseLocationURL @"http://120.25.80.143:3000/lbs/loc/beacon/" //推送/更新室内位置
#define kJavaBaseGPSURL @"http://120.25.80.143:3000/lbs/loc/gps/" //推送/更新室外位置

#endif /* Configure_h */
