//
//  ZKJSLocationHTTPSessionManager.h
//  SVIP
//
//  Created by AlexBang on 16/2/23.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"

@interface ZKJSLocationHTTPSessionManager : AFHTTPRequestOperationManager
@property (nonatomic,retain)AFHTTPRequestOperationManager * manager;


#pragma mark - 单例
+ (instancetype)sharedInstance;

#pragma mark - 推送/更新室内位置
- (void)regionalPositionChangeNoticeWithMajor:(NSString *)major minior:(NSString *)minior uuid:(NSString *)uuid sensorid:(NSString *)sensorid timestamp:(NSInteger)timestamp success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


#pragma mark - 推送/更新室外位置
- (void)GPSPositionChangeNoticeWithLatitude:(NSString *)latitude longitude:(NSString *)longitude altitude:(NSString *)altitude timestamp:(integer_t)timestamp success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark -获取手机验证码
- (void)requestSmsCodeWithPhoneNumber:(NSString *)phone success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
#pragma mark -使用手机验证码和手机获取Token
- (void)loginWithCode:(NSString *)code phone:(NSString *)phone success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


@end
