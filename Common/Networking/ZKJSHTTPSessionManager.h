//
//  ZKJSHTTPSessionManager.h
//  HotelVIP
//
//  Created by Hanton on 6/1/15.
//  Copyright (c) 2015 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface ZKJSHTTPSessionManager : AFHTTPSessionManager
// 单例
+ (instancetype)sharedInstance;
// 获取Beacon列表
- (void)getBeaconRegionListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 注册
- (void)userSignUpWithPhone:(NSString *)phone success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 登录
- (void)userLoginWithPhone:(NSString *)phone password:(NSString *)password rememberMe:(NSString *)rememberMe success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 匿名登录
- (void)visitorSignUpWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 登出
- (void)logoutWithUserID:(NSString *)userID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 检查重复手机
- (void)checkDuplicatePhoneWithPhone:(NSString *)phone success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 修改帐号密码
- (void)changeAccountPasswordWithPhone:(NSString *)phone newPassword:(NSString *)newPassword success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 修改用户信息
- (void)updateUserInfoWithUserID:(NSString *)userID token:(NSString *)token userName:(NSString *)userName imageData:(NSData *)imageData imageName:(NSString *)imageName sex:(NSString *)sex company:(NSString *)company occupation:(NSString *)occupation success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 取得用户头像
- (UIImage *)getUserProfileWithUserID:(NSString *)userID;
// 取得用户信息
- (void)getUserInfo:(NSString *)userID token:(NSString *)token success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 取得商家信息
- (void)getShopInfo:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 取得指定条件的商家信息
- (void)getAllShopInfoWithStart:(NSInteger)start page:(NSInteger)page key:(NSString *)key isDesc:(BOOL)isDesc success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
- (void)getShopCommentsWithShopID:(NSString *)shopID start:(NSInteger)start page:(NSInteger)page key:(NSString *)key isDesc:(BOOL)isDesc success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 取得标签
- (void)getTagsShowTreeWithCallback:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
- (void)getTagsShowWithCallback:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 上传用户标签
- (void)updateTagsWithUserID:(NSString *)userID token:(NSString *)token tags:(NSString *)tags success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 上传酒店订单
- (void)postBookingInfoWithUserID:(NSString *)userID token:(NSString *)token shopID:(NSString *)shopID goodsID:(NSString *)goodsID guest:(NSString *)guest guestPhone:(NSString *)guestPhone roomNum:(NSString *)roomNum arrivalDate:(NSString *)arrivalDate departureDate:(NSString *)departureDate roomType:(NSString *)roomType roomRate:(NSString *)roomRate remark:(NSString *)remark success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 获取商品列表
//- (void)getShopGoodsWithShopID:(NSString *)shopID page:(NSInteger)page categoryID:(NSString *)categoryID key:(NSString *)key success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
- (void)getShopGoodsPage:(NSInteger)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 获取商品
- (void)getShopGoodsWithShopID:(NSString *)shopID goodsID:(NSString *)goodsID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 获取商品分类
- (void)getShopGoodsCategoryWith:(NSString *)categoryID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 订单列表
- (void)getOrderListWithUserID:(NSString *)userID token:(NSString *)token page:(NSString *)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 最近一张订单
- (void)getLatestOrderWithUserID:(NSString *)userID token:(NSString *)token success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 取消订单
- (void)cancelOrderWithUserID:(NSString *)userID token:(NSString *)token orderID:(NSString *)orderID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 删除订单
- (void)deleteOrderWithUserID:(NSString *)userID token:(NSString *)token orderID:(NSString *)orderID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
