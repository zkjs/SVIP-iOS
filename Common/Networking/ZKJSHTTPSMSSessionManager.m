//
//  ZKJSHTTPSMSSessionManager.m
//  HotelVIP
//
//  Created by Hanton on 6/6/15.
//  Copyright (c) 2015 ZKJS. All rights reserved.
//

#import "ZKJSHTTPSMSSessionManager.h"
#import "CCPRestSDK.h"

// 正式版
static NSString* const appID = @"8a48b5514f73ea32014f8d1d3f71344d";
static NSString* const token = @"137d18e0111643ffb9e06401f214cc8d";
static NSString* const restURL = @"app.cloopen.com";
static NSString* const templateID = @"50157";

// 测试版本
//static NSString* const appID = @"aaf98f894d985d36014d99d2196e0266";
//static NSString* const token = @"0e48533de702931f037558521133dce2";
//static NSString* const restURL = @"sandboxapp.cloopen.com";
//static NSString* const templateID = @"1";

@interface ZKJSHTTPSMSSessionManager ()

@property (nonatomic, strong) NSMutableDictionary *phoneSMS;
@property (nonatomic, strong) CCPRestSDK *ccpRestSdk;

@end

@implementation ZKJSHTTPSMSSessionManager

+ (instancetype)sharedInstance {
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    self.phoneSMS = [NSMutableDictionary dictionary];
    self.ccpRestSdk = [[CCPRestSDK alloc] initWithServerIP: restURL andserverPort: 8883];
    [self.ccpRestSdk setApp_ID: appID];
    [self.ccpRestSdk enableLog: YES];
    [self.ccpRestSdk setAccountWithAccountSid: @"8a48b5514d9861c3014d99cf3572024a" andAccountToken: token];
  }
  return self;
}

// 发送短信验证码
- (void)requestSmsCodeWithPhoneNumber:(NSString *)phone callback:(void (^)(BOOL succeeded, NSError *error))callback {
  NSString *verifyCode = [NSString stringWithFormat:@"%d%d%d%d%d%d", arc4random() % 9 + 1, arc4random() % 10, arc4random() % 10, arc4random() % 10, arc4random() % 10, arc4random() % 10];
  NSString *verifyTime = @"5";
  NSArray *datas = [NSArray arrayWithObjects: verifyCode, verifyTime, nil];
  NSMutableDictionary *dict = [self.ccpRestSdk sendTemplateSMSWithTo:phone andTemplateId:templateID andDatas:datas];
  NSLog(@"%@", verifyCode);
  self.phoneSMS[phone] = verifyCode;
  if ([dict[@"statusCode"] isEqualToString:@"000000"]) {
    // statusMsg = "成功"
    callback(YES, nil);
  } else {
    NSLog(@"%@", [dict description]);
    NSError *error = [[NSError alloc] initWithDomain:@"验证码错误" code:999 userInfo:dict];
    callback(NO, error);
  }
}

// 检查短信验证码
- (void)verifySmsCode:(NSString *)code mobilePhoneNumber:(NSString *)phone callback:(void (^)(BOOL succeeded, NSError *error))callback {
#if DEBUG
  callback(YES, nil);
#else
  NSString *verifycode = self.phoneSMS[phone];
  if ([code isEqualToString:verifycode]) {
    callback(YES, nil);
  } else {
    callback(NO, nil);
  }
#endif
}

@end
