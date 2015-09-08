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
    self.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
//    [self.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Accept"];
//    [self.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    self.responseSerializer = [[AFJSONResponseSerializer alloc] init];
  }
  return self;
}

// 上传语音文件
- (void)uploadAudioWithFromID:(NSString *)fromID sessionID:(NSString *)sessionID shopID:(NSString *)shopID format:(NSString *)format body:(NSString *)body success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"media/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[fromID dataUsingEncoding:NSUTF8StringEncoding] name:@"FromID"];
    [formData appendPartWithFormData:[sessionID dataUsingEncoding:NSUTF8StringEncoding] name:@"SessionID"];
    [formData appendPartWithFormData:[shopID dataUsingEncoding:NSUTF8StringEncoding] name:@"ShopID"];
    [formData appendPartWithFormData:[format dataUsingEncoding:NSUTF8StringEncoding] name:@"Format"];
    [formData appendPartWithFormData:[body dataUsingEncoding:NSUTF8StringEncoding] name:@"Body"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 上传图片文件
- (void)uploadPictureWithFromID:(NSString *)fromID sessionID:(NSString *)sessionID shopID:(NSString *)shopID format:(NSString *)format body:(NSString *)body success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"img/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[fromID dataUsingEncoding:NSUTF8StringEncoding] name:@"FromID"];
    [formData appendPartWithFormData:[sessionID dataUsingEncoding:NSUTF8StringEncoding] name:@"SessionID"];
    [formData appendPartWithFormData:[shopID dataUsingEncoding:NSUTF8StringEncoding] name:@"ShopID"];
    [formData appendPartWithFormData:[format dataUsingEncoding:NSUTF8StringEncoding] name:@"Format"];
    [formData appendPartWithFormData:[body dataUsingEncoding:NSUTF8StringEncoding] name:@"Body"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

@end
