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
//#define kJavaBaseURL @"app.zkjinshi.com/japi" // Java服务器正式地址

@interface ZKJSJavaHTTPSessionManager : AFHTTPSessionManager

#pragma mark - 单例
+ (instancetype)sharedInstance;

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

#pragma mark - 查询所有的酒店列表(未登录时的)
- (void)getLoginOutShopListWithPage:(NSString *)page size:(NSString *)size success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
#pragma mark - 首页大图
- (void)getHomeImageWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


#pragma mark - 获取用户推送消息(用户未登陆)
- (void)getPushInfoToUserWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 获取用户订单状态消息
- (void)getOrderWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 根据电话查询用户
- (void)checkSalesWithPhone:(NSString *)phone Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 根据商户编号查询商户
- (void)accordingMerchantNumberInquiryMerchantWithShopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 根据酒店区域获取用户特权
- (void)getPrivilegeWithShopID:(NSString *)shopID locID:(NSString *)locID Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

# pragma mark - 获取订单列表
- (void)getOrderListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

# pragma mark - 获取订单详情
- (void)getOrderDetailWithOrderNo:(NSString *)orderno Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

# pragma mark - 订单新增
- (void)addOrderWithCategory:(NSString *)category data:(NSDictionary *)data Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

# pragma mark - 获取商家详情
- (void)getOrderDetailWithShopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
