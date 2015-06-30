//
//  ZKJSHTTPSMSSessionManager.m
//  HotelVIP
//
//  Created by Hanton on 6/6/15.
//  Copyright (c) 2015 ZKJS. All rights reserved.
//

#import "ZKJSHTTPSMSSessionManager.h"
#import <CommonCrypto/CommonDigest.h>

@interface ZKJSHTTPSMSSessionManager ()
@property (nonatomic, strong) NSMutableDictionary *phoneSMS;
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
    NSString *mainAccount = @"8a48b5514d9861c3014d99cf3572024a";
    NSString *timestamp = [self getTimestamp];
    NSString *authorizationString = [self getMainAuthorization:[NSString stringWithFormat:@"%@:%@", mainAccount, timestamp]];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerializer setValue:authorizationString forHTTPHeaderField:@"Authorization"];
    self.requestSerializer = requestSerializer;
    self.responseSerializer = [[AFJSONResponseSerializer alloc] init];
  }
  return self;
}

// 发送短信验证码
- (void)requestSmsCodeWithPhoneNumber:(NSString *)phone callback:(void (^)(BOOL succeeded, NSError *error))callback {
  NSString *serverIP = @"app.cloopen.com";
  int serverPort = 8883;
  NSString *appID = @"aaf98f894d985d36014d9a1e19f702bb";
  NSString *serverVersion = @"2013-12-26";
  NSString *mainAccount = @"8a48b5514d9861c3014d99cf3572024a";
  NSString *mainToken = @"137d18e0111643ffb9e06401f214cc8d";
  NSString *timestamp = [self getTimestamp];
  NSString *mainSig = [self getMainSig:[NSString stringWithFormat:@"%@%@%@", mainAccount, mainToken, timestamp]];
  NSString *requestURL = [NSString stringWithFormat:@"https://%@:%d/%@/Accounts/%@/SMS/TemplateSMS?sig=%@", serverIP, serverPort, serverVersion, mainAccount, mainSig];
  NSString *verifyCode = [NSString stringWithFormat:@"%d%d%d%d%d%d", arc4random() % 9 + 1, arc4random() % 10, arc4random() % 10, arc4random() % 10, arc4random() % 10, arc4random() % 10];
  NSString *verifyTime = @"5";
  NSArray *datas = @[verifyCode, verifyTime];
  NSDictionary *parameters = @{
                               @"to": phone,
                               @"appId": appID,
                               @"templateId": @"22143",
                               @"datas": datas
                               };
  
  [self POST:requestURL parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", responseObject[@"statusMsg"]);
    self.phoneSMS[phone] = verifyCode;
    callback(YES, nil);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    callback(NO, error);
  }];
}

// 检查短信验证码
- (void)verifySmsCode:(NSString *)code mobilePhoneNumber:(NSString *)phone callback:(void (^)(BOOL succeeded, NSError *error))callback {
  NSString *verifycode = self.phoneSMS[phone];
  if ([code isEqualToString:verifycode]) {
    callback(YES, nil);
  } else {
    callback(NO, nil);
  }
}

#pragma mark - Private Methods

// 获取主帐号sig编码
- (NSString *)getMainSig:(NSString *)sigString
{
  const char *cStr = [sigString UTF8String];
  unsigned char result[16];
  CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
  return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

// 得到当前时间的字符串
- (NSString *)getTimestamp
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
  NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
  return currentDateStr;
}

// 根据主帐号sid和当前时间字符串获取一个Authorization编码
- (NSString *)getMainAuthorization:(NSString *)authorizationString
{
  return [self base64forData:[authorizationString dataUsingEncoding:NSUTF8StringEncoding]];
}

// base64编码
- (NSString*)base64forData:(NSData*)theData {
  
  const uint8_t* input = (const uint8_t*)[theData bytes];
  NSInteger length = [theData length];
  
  static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
  
  NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
  uint8_t* output = (uint8_t*)data.mutableBytes;
  
  NSInteger i,i2;
  for (i=0; i < length; i += 3) {
    NSInteger value = 0;
    for (i2=0; i2<3; i2++) {
      value <<= 8;
      if (i+i2 < length) {
        value |= (0xFF & input[i+i2]);
      }
    }
    
    NSInteger theIndex = (i / 3) * 4;
    output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
    output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
    output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
    output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
  }
  
  return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
