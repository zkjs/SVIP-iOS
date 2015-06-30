//
//  ZKJSHTTPSMSSessionManager.h
//  HotelVIP
//
//  Created by Hanton on 6/6/15.
//  Copyright (c) 2015 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface ZKJSHTTPSMSSessionManager : AFHTTPSessionManager
// 单例
+ (instancetype)sharedInstance;
// 短信验证
- (void)requestSmsCodeWithPhoneNumber:(NSString *)phone callback:(void (^)(BOOL succeeded, NSError *error))callback;
- (void)verifySmsCode:(NSString *)code mobilePhoneNumber:(NSString *)phone callback:(void (^)(BOOL succeeded, NSError *error))callback;
@end
