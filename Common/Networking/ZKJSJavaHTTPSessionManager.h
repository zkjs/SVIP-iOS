//
//  ZKJSJavaHTTPSessionManager.h
//  SuperService
//
//  Created by Hanton on 12/13/15.
//  Copyright © 2015 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

#define kJavaBaseURL @"http://mmm.zkjinshi.com/" // Java HTTP服务器测试地址

@interface ZKJSJavaHTTPSessionManager : AFHTTPSessionManager

#pragma mark - 单例
+ (instancetype)sharedInstance;

#pragma mark - Public
- (NSString *)domain;

#pragma mark - 查询所有的酒店列表
- (void)getShopListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
#pragma mark - 获取同步的到店列表
- (void)getSynchronizedStoreListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
#pragma mark - 首页大图
- (void)getHomeImageWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
