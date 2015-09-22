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
    self.responseSerializer = [[AFJSONResponseSerializer alloc] init];
  }
  return self;
}

// 上传语音文件
- (void)uploadAudioWithFromID:(NSString *)fromID sessionID:(NSString *)sessionID shopID:(NSString *)shopID format:(NSString *)format body:(NSData *)body success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  
  NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
  [parameters setObject:fromID forKey:@"FromID"];
  [parameters setObject:sessionID forKey:@"SessionID"];
  [parameters setObject:shopID forKey:@"ShopID"];
  [parameters setObject:format forKey:@"Format"];
  [parameters setObject:[[NSUUID UUID] UUIDString] forKey:@"TempID"];
  
  [self POST:@"media/upload" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    [formData appendPartWithFileData:body name:@"Body" fileName:@"audio.aac" mimeType:@"audio/aac"];
  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    DDLogInfo(@"%@", error.localizedDescription);
    failure(task, error);
  }];
}

// 上传图片文件
- (void)uploadPictureWithFromID:(NSString *)fromID sessionID:(NSString *)sessionID shopID:(NSString *)shopID format:(NSString *)format image:(UIImage *)image success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  CGFloat compression = 0.9f;
  CGFloat maxCompression = 0.1f;
  int maxFileSize = 700*1024;//1024*1024;  //整个消息包最大1M,图片大约最大700K
  NSData *imageData = UIImageJPEGRepresentation(image, compression);
  while ([imageData length] > maxFileSize && compression > maxCompression) {
    compression -= 0.1;
    imageData = UIImageJPEGRepresentation(image, compression);
  }
  NSLog(@"Image Size: %fK", [imageData length]/1024.0);
  
  NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
  [parameters setObject:fromID forKey:@"FromID"];
  [parameters setObject:sessionID forKey:@"SessionID"];
  [parameters setObject:shopID forKey:@"ShopID"];
  [parameters setObject:format forKey:@"Format"];
  [parameters setObject:[[NSUUID UUID] UUIDString] forKey:@"TempID"];
  
  [self POST:@"img/upload" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    [formData appendPartWithFileData:imageData name:@"Body" fileName:@"image.jpg" mimeType:@"image/jpeg"];
  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    DDLogInfo(@"%@", error);
    failure(task, error);
  }];
}

// 查看消息记录
- (void)getChatLogWithUserID:(NSString *)userID shopID:(NSString *)shopID fromTime:(NSNumber *)fromTime count:(NSNumber *)count success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  
  [self POST:@"msg/find/clientid" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"ClientID"];
    [formData appendPartWithFormData:[shopID dataUsingEncoding:NSUTF8StringEncoding] name:@"ShopID"];
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"UserID"];
    [formData appendPartWithFormData:[[fromTime stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"FromTime"];
    [formData appendPartWithFormData:[[count stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"Count"];
  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

@end
