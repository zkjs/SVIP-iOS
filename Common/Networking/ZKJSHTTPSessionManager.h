//
//  ZKJSHTTPSessionManager.h
//  HotelVIP
//
//  Created by Hanton on 6/1/15.
//  Copyright (c) 2015 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@import UIKit;

@interface ZKJSHTTPSessionManager : AFHTTPSessionManager
// 单例
+ (instancetype)sharedInstance;
// 获取Beacon列表
- (void)getBeaconRegionListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 注册
- (void)userSignUpWithPhone:(NSString *)phone openID:(NSString *)openID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 判断用户手机和微信第三方id是否已经注册过
- (void)verifyIsRegisteredWithID:(NSString *)__id success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 登出
- (void)logoutWithUserID:(NSString *)userID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 检查重复手机
- (void)checkDuplicatePhoneWithPhone:(NSString *)phone success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 修改帐号密码
- (void)changeAccountPasswordWithPhone:(NSString *)phone newPassword:(NSString *)newPassword success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 修改用户信息
- (void)updateUserInfoWithUserID:(NSString *)userID token:(NSString *)token username:(NSString *)username realname:(NSString *)realname imageData:(NSData *)imageData imageName:(NSString *)imageName sex:(NSString *)sex company:(NSString *)company occupation:(NSString *)occupation email:(NSString *)email tagopen:(NSNumber *)tagopen success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
- (void)updateUserInfoWithParaDic:(NSDictionary *)paraDic success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 获取默认发票
- (void)getDefaultInvoiceSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 获取发票列表
- (void)getInvoiceListSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 添加发票
- (void)addInvoiceWithTitle:(NSString *)title isDefault:(BOOL)isDefault Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 修改发票
- (void)modifyInvoiceWithInvoiceid:(NSString *)invoiceid title:(NSString *)title isDefault:(BOOL)isDefault Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 删除发票
- (void)deleteInvoiceWithInvoiceid:(NSString *)invoiceid Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 取得用户头像
- (UIImage *)getUserProfileWithUserID:(NSString *)userID;
// 取得用户信息
- (void)getUserInfo:(NSString *)userID token:(NSString *)token success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 取得商家信息
- (void)getShopInfo:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 取得指定条件的商家列表信息
- (void)getAllShopInfoWithPage:(NSInteger)page key:(NSString *)key isDesc:(BOOL)isDesc success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
- (void)getShopCommentsWithShopID:(NSString *)shopID start:(NSInteger)start page:(NSInteger)page key:(NSString *)key isDesc:(BOOL)isDesc success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 取得已有标签
- (void)getSelectedTagsWithID:(NSString *)userID token:(NSString *)token success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 获取随机标签池
- (void)getRandomTagsWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 上传用户标签
- (void)updateTagsWithUserID:(NSString *)userID token:(NSString *)token tags:(NSString *)tags success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 获取订单详情
- (void)getOrderWithReservation_no:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 修改订单
- (void)modifyOrderWithReservation_no:(NSString *)reservation_no param:(NSDictionary *)param success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 取消订单
- (void)cancelOrderWithReservation_no:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 上传酒店订单
- (void)postBookingInfoWithUserID:(NSString *)userID token:(NSString *)token shopID:(NSString *)shopID goodsID:(NSString *)goodsID guest:(NSString *)guest guestPhone:(NSString *)guestPhone roomNum:(NSString *)roomNum arrivalDate:(NSString *)arrivalDate departureDate:(NSString *)departureDate roomType:(NSString *)roomType roomRate:(NSString *)roomRate remark:(NSString *)remark success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 获取指定商家的商品列表
- (void)getShopGoodsListWithShopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 获取所有商品列表
- (void)getShopGoodsPage:(NSInteger)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 获取商品
- (void)getShopGoodsWithShopID:(NSString *)shopID goodsID:(NSString *)goodsID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 获取商品分类
- (void)getShopGoodsCategoryWith:(NSString *)categoryID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 订单列表
- (void)getOrderListWithUserID:(NSString *)userID token:(NSString *)token page:(NSString *)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 历史订单列表
- (void)getOrderHistoryListWithUserID:(NSString *)userID token:(NSString *)token page:(NSString *)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 最近一张订单
- (void)getLatestOrderWithUserID:(NSString *)userID token:(NSString *)token success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 取消订单
- (void)cancelOrderWithUserID:(NSString *)userID token:(NSString *)token reservation_no:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 删除订单
- (void)deleteOrderWithUserID:(NSString *)userID token:(NSString *)token reservation_no:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// 提交轨迹
- (void)postGPSWithUserID:(NSString *)userID token:(NSString *)token longitude:(NSString *)longitude latitude:(NSString *)latitude traceTime:(NSString *)traceTime success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
