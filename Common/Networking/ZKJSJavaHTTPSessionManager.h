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
#pragma mark - 区域位置变化通知
- (void)regionalPositionChangeNoticeWithUserID:(NSString *)userID locID:(NSString *)locID shopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark -获取同步的到店列表
- (void)getSynchronizedStoreListWithShopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 根据城市名称查询酒店列表
- (void)getShopListWithCity:(NSString *)city page:(NSString *)page size:(NSString *)size Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 获取推荐商家列表
- (void)getRecommendShopListWithCity:(NSString *)city  Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 查询所有的酒店列表
- (void)getShopListWithPage:(NSString *)page size:(NSString *)size success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 首页大图
- (void)getHomeImageWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


#pragma mark - 获取用户推送消息(用户未登陆)
- (void)getPushInfoToUserWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 获取用户订单状态消息
- (void)getOrderWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 根据商户编号查询商户
- (void)accordingMerchantNumberInquiryMerchantWithShopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
