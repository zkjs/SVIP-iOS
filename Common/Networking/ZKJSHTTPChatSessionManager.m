//
//  ZKJSHTTPChatSessionManager.m
//  SVIP
//
//  Created by Hanton on 9/7/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import "ZKJSHTTPChatSessionManager.h"
#import "Networkcfg.h"
#import "CocoaLumberjack.h"

static const DDLogLevel ddLogLevel = DDLogLevelInfo;

@implementation ZKJSHTTPChatSessionManager

+ (instancetype)sharedInstance {
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super initWithBaseURL:[[NSURL alloc] initWithString:kChatBaseURL]];
  if (self) {
    self.requestSerializer = [[AFJSONRequestSerializer alloc] init];
    self.responseSerializer = [[AFJSONResponseSerializer alloc] init];
  }
  return self;
}

// 上传语音文件
- (void)uploadAudioWithFromID:(NSString *)fromID sessionID:(NSString *)sessionID shopID:(NSString *)shopID format:(NSString *)format body:(NSString *)body success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary *dictionary = @{@"FromID" : fromID,
                               @"SessionID" : sessionID,
                               @"ShopID" : shopID,
                               @"Format": format,
                               @"Body": body
                               };
  [self POST:@"media/upload" parameters:dictionary success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 上传图片文件
- (void)uploadPictureWithFromID:(NSString *)fromID sessionID:(NSString *)sessionID shopID:(NSString *)shopID format:(NSString *)format body:(NSString *)body success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary *dictionary = @{@"FromID" : fromID,
                               @"SessionID" : sessionID,
                               @"ShopID" : shopID,
                               @"Format": format,
                               @"Body": body
                               };
  [self POST:@"img/upload" parameters:dictionary success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

@end
