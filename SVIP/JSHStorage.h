//
//  JSGStorage.h
//  BeaconMall
//
//  Created by dai.fengyi on 4/28/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "JSHUserInfo.h"
#import "JSHBaseInfo.h"

@interface JSHStorage : NSObject
//single_interface(JSHStorage)
/*保留为以后扩展
+ (NSString *)cacheDirectory;
+ (NSString *)documentDirectory;
+ (NSString *)libraryDirectory;
+ (NSString *)homeDirectory;
+ (NSString *)temporaryDirectory;

+ (NSString *)imageCachesFolder;
+ (NSString *)dataCachesFolder;

//创建并返回目录
+ (NSString *)creatCacheSubFolder:(NSString *)folder;
+ (NSString *)creatDocumentSubFolder:(NSString *)folder;
+ (NSString *)creatFolder:(NSString *)folder path:(NSString *)path;

//读登陆列表
+ (NSArray *)readLoginList;
//写登陆信息进列表（NSUserDefault）
+ (void)saveLoginListWithUsername:(NSString *)username password:(NSString *)password;

+ (BOOL)isNewVersion;
*/


//JSH具体业务
//deviceToken
+ (NSString *)deviceToken;
+ (void)saveDeviceToken:(NSString *)deviceToken;

/* dai 权宜之计，弃用userInfo，使用baseInfo和likeArray
//userInfo
+ (JSHUserInfo *)userInfo;
+ (void)saveUserInfo:(JSHUserInfo *)userInfo;
*/
//baseInfo
+ (JSHBaseInfo *)baseInfo;
+ (void)saveBaseInfo:(JSHBaseInfo *)baseInfo;

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