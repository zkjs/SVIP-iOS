//
//  ZKJSHTTPChatSessionManager.h
//  SVIP
//
//  Created by Hanton on 9/7/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface ZKJSHTTPChatSessionManager : AFHTTPSessionManager
+ (instancetype)sharedInstance;
// 上传语音文件
- (void)uploadAudioWithFromID:(NSString *)fromID sessionID:(NSString *)sessionID shopID:(NSString *)shopID format:(NSString *)format body:(NSString *)body success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 上传图片文件
- (void)uploadPictureWithFromID:(NSString *)fromID sessionID:(NSString *)sessionID shopID:(NSString *)shopID format:(NSString *)format body:(NSString *)body success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
