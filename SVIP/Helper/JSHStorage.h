//
//  JSGStorage.h
//  BeaconMall
//
//  Created by dai.fengyi on 4/28/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSHStorage : NSObject


//JSH具体业务
//deviceToken
+ (NSString *)deviceToken;
+ (void)saveDeviceToken:(NSString *)deviceToken;

/* dai 权宜之计，弃用userInfo，使用baseInfo和likeArray
//userInfo
+ (JSHUserInfo *)userInfo;
+ (void)saveUserInfo:(JSHUserInfo *)userInfo;
*/

+ (void)saveBaseInfoAvatar:(UIImage *)avatar;//或者存image，或者存url，此处为存image做该方法

//likeArray
+ (NSArray *)likeArray;
+ (void)saveLikeArray:(NSArray *)likeArray;

// Hanton
// 缓存酒店信息(ID:120)
+ (NSDictionary *)shopInfo;
+ (void)saveShopInfo:(NSDictionary *)shopInfo;

// 缓存酒店房型列表
+ (NSArray *)hotelRooms;
+ (void)saveHotelRooms:(NSArray *)hotelRooms;

// 缓存商家列表
+ (NSDictionary *)shopsInfo;
+ (void)saveShopsInfo:(NSDictionary *)shopsInfo;

// 缓存Beacon区域信息
+ (NSDictionary *)beaconRegions;
+ (void)saveBeaconRegions:(NSDictionary *)beaconRegions;

// 缓存订单信息
+ (NSArray *)bookingOrders;
+ (void)saveBookingOrders:(NSArray *)bookingOrders;

// 缓存TCP Server的IP和Port
+ (NSDictionary *)tcpServer;
+ (void)saveTCPServer:(NSDictionary *)tcpServer;

@end