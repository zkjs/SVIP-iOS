//
//  JSGStorage.m
//  BeaconMall
//
//  Created by dai.fengyi on 4/28/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import "JSHStorage.h"

#define JSGCache           [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]             //  cache目录
#define JSGDocument        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]      //  document目录
#define JSGLibrary         [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]            //  library目录
#define JSGHome            NSHomeDirectory()                                                                                       //  home目录
#define JSGTemporary       NSTemporaryDirectory()                                                                                  //  temp目录

#define kLoginInfo          @"kLoginInfo"
#define kDeviceToken        @"kDeviceToken"
#define kUserInfo           @"kUserInfo.archive"
#define kBaseInfo           @"kBaseInfo.archive"
#define kLikeArray          @"kLikeArray.archive"
#define kShopsInfo          @"kShopsInfo.archive"
#define kBeaconRegions          @"kBeaconRegions.archive"
@implementation JSHStorage
//single_implementation(JSHStorage)
+ (void)initialize
{
    [self creatCacheSubFolder:@"imagesCaches"];
    [self creatCacheSubFolder:@"dataCaches"];
}

+ (NSString *)cacheDirectory
{
    return JSGCache;
}
+ (NSString *)documentDirectory
{
    return JSGDocument;
}
+ (NSString *)libraryDirectory
{
    return JSGLibrary;
}
+ (NSString *)homeDirectory
{
    return JSGHome;
}
+ (NSString *)temporaryDirectory
{
    return JSGTemporary;
}


+ (NSString *)imageCachesFolder
{
    return [JSGCache stringByAppendingPathComponent:@"imageCaches"];
}
+ (NSString *)dataCachesFolder
{
    return [JSGCache stringByAppendingPathComponent:@"dataCaches"];
}


+ (NSString *)creatCacheSubFolder:(NSString *)folder
{
    return [self creatFolder:folder path:JSGCache];
}

+ (NSString *)creatDocumentSubFolder:(NSString *)folder
{
    return [self creatFolder:folder path:JSGDocument];
}
+ (NSString *)creatFolder:(NSString *)folder path:(NSString *)path
{
    //1. 初始化NSFileManager
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    //2. 拼接新目录字符串path/folder
    NSString *newFolder = nil;
    if ([fileManager fileExistsAtPath:path]) {
        newFolder = [path stringByAppendingPathComponent:folder];
    }else {
        NSLog(@"路径path不存在，转存到Caches目录");
        newFolder = [JSGCache  stringByAppendingPathComponent:path];
    }
    return newFolder;
}

/*
//字典可加入 rememberPassword:(BOOL)rememberPassword autoLogin:(BOOL)autoLogin两个字段
+ (void)saveLoginListWithUsername:(NSString *)username password:(NSString *)password
{
    NSMutableArray *mutArr = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginInfo];
    if (mutArr == nil) {
        mutArr = [NSMutableArray arrayWithObject:@{@"username" : username, @"password" : password}];
    }else {
        for (NSDictionary *dic in mutArr) {
            //已存在，则更新密码
            if ([[dic objectForKey:@"username"] isEqualToString:username]) {
                [dic setValue:password forKey:@"usernaem"];
                [[NSUserDefaults standardUserDefaults] setObject:mutArr forKey:kLoginInfo];
                [[NSUserDefaults standardUserDefaults] synchronize];
                return;
            }
        }
        [mutArr insertObject:@{username : password} atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:mutArr forKey:kLoginInfo];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *)readLoginList
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLoginInfo];
}

+ (BOOL)isNewVersion
{
    NSString *key = (NSString *)kCFBundleVersionKey;
    NSString *version = [NSBundle mainBundle].infoDictionary[key];
    NSString *savedVersion = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if ([version isEqualToString:savedVersion]) {
        return NO;
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
}
*/
#pragma mark - JSH业务
+ (NSString *)deviceToken
{
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
    if (!deviceToken) {
        deviceToken = @"";
    }
    return deviceToken;
}
+ (void)saveDeviceToken:(NSString *)deviceToken
{
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:kDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (JSHUserInfo *)userInfo
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[JSHStorage cacheDirectory] stringByAppendingPathComponent:kUserInfo]];
}
+ (void)saveUserInfo:(JSHUserInfo *)userInfo
{
    [NSKeyedArchiver archiveRootObject:userInfo toFile:[[JSHStorage cacheDirectory] stringByAppendingPathComponent:kUserInfo]];
}

//baseInfo
+ (JSHBaseInfo *)baseInfo{
//    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[JSHStorage cacheDirectory] stringByAppendingPathComponent:kBaseInfo]];
    JSHBaseInfo *baseInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:[[JSHStorage cacheDirectory] stringByAppendingPathComponent:kBaseInfo]];
    if (baseInfo == nil) {
        baseInfo = [[JSHBaseInfo alloc] init];
        baseInfo.phone = @"请编辑个人信息";//根据该字段判断是否是正常值还是缺省值
    }
    return baseInfo;
}
+ (void)saveBaseInfo:(JSHBaseInfo *)baseInfo{
    NSString *path = [[JSHStorage cacheDirectory] stringByAppendingPathComponent:kBaseInfo];
    [NSKeyedArchiver archiveRootObject:baseInfo toFile:path];
}

+ (void)saveBaseInfoAvatar:(UIImage *)avatar{
    JSHBaseInfo *baseInfo = [self baseInfo];
    baseInfo.avatarImage = avatar;
    [self saveBaseInfo:baseInfo];
}

//likeArray
+ (NSArray *)likeArray {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[JSHStorage cacheDirectory] stringByAppendingPathComponent:kLikeArray]];

}
+ (void)saveLikeArray:(NSArray *)likeArray {
    [NSKeyedArchiver archiveRootObject:likeArray toFile:[[JSHStorage cacheDirectory] stringByAppendingPathComponent:kLikeArray]];
}

// Hanton
// 缓存酒店信息(ID:120)
+ (NSDictionary *)shopInfo {
  NSString *path = [[self documentDirectory] stringByAppendingPathComponent:@"JSHHotel.plist"];
  NSDictionary *shopInfo = [NSDictionary dictionary];
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  if ([fileManager fileExistsAtPath:path]) {
    shopInfo = [NSDictionary dictionaryWithContentsOfFile:path];
  } else {
    path = [[NSBundle mainBundle] pathForResource:@"JSHHotel" ofType:@"plist"];
    shopInfo = [NSDictionary dictionaryWithContentsOfFile:path];
  }
  return shopInfo;
}

+ (void)saveShopInfo:(NSDictionary *)shopInfo {
  NSString *path = [[self documentDirectory] stringByAppendingPathComponent:@"JSHHotel.plist"];
  [shopInfo writeToFile:path atomically:YES];
}

// 缓存酒店房型列表
+ (NSArray *)hotelRooms {
  NSString *path = [[self documentDirectory] stringByAppendingPathComponent:@"JSHHotelRooms.plist"];
  NSArray *hotelRooms = [NSArray array];
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  if ([fileManager fileExistsAtPath:path]) {
    hotelRooms = [NSArray arrayWithContentsOfFile:path];
  } else {
    path = [[NSBundle mainBundle] pathForResource:@"JSHHotelRooms" ofType:@"plist"];
    hotelRooms = [NSArray arrayWithContentsOfFile:path];
  }
  return hotelRooms;
}

+ (void)saveHotelRooms:(NSArray *)hotelRooms {
  NSString *path = [[self documentDirectory] stringByAppendingPathComponent:@"JSHHotelRooms.plist"];
  [hotelRooms writeToFile:path atomically:YES];
}

// 缓存商家列表
+ (NSDictionary *)shopsInfo {
  NSString *path = [[self documentDirectory] stringByAppendingPathComponent:@"JSHHotels.plist"];
  NSDictionary *shopsInfo = [NSDictionary dictionary];
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  if ([fileManager fileExistsAtPath:path]) {
    shopsInfo = [NSDictionary dictionaryWithContentsOfFile:path];
  } else {
    path = [[NSBundle mainBundle] pathForResource:@"JSHHotels" ofType:@"plist"];
    shopsInfo = [NSDictionary dictionaryWithContentsOfFile:path];
  }
  return shopsInfo;
}

+ (void)saveShopsInfo:(NSDictionary *)shopsInfo {
  NSString *path = [[self documentDirectory] stringByAppendingPathComponent:@"JSHHotels.plist"];
  [shopsInfo writeToFile:path atomically:YES];
}

// 缓存Beacon区域信息
+ (NSDictionary *)beaconRegions {
  return [NSKeyedUnarchiver unarchiveObjectWithFile:[[self documentDirectory] stringByAppendingPathComponent:kBeaconRegions]];
}

+ (void)saveBeaconRegions:(NSDictionary *)beaconRegions {
  [NSKeyedArchiver archiveRootObject:beaconRegions toFile:[[self documentDirectory] stringByAppendingPathComponent:kBeaconRegions]];
}

// 缓存订单信息
+ (NSArray *)bookingOrders {
  NSString *path = [[self documentDirectory] stringByAppendingPathComponent:@"JSHBookingOrders.plist"];
  NSArray *bookingOrders = [NSArray array];
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  if ([fileManager fileExistsAtPath:path]) {
    bookingOrders = [NSArray arrayWithContentsOfFile:path];
  } else {
    bookingOrders = nil;
  }
  return bookingOrders;
}

+ (void)saveBookingOrders:(NSArray *)bookingOrders {
  NSString *path = [[self documentDirectory] stringByAppendingPathComponent:@"JSHBookingOrders.plist"];
  [bookingOrders writeToFile:path atomically:YES];
}

// 缓存TCP服务器的IP和Port
+ (NSDictionary *)tcpServer {
  NSString *path = [[self documentDirectory] stringByAppendingPathComponent:@"JSHTCPServer.plist"];
  NSDictionary *shopsInfo = [NSDictionary dictionary];
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  if ([fileManager fileExistsAtPath:path]) {
    shopsInfo = [NSDictionary dictionaryWithContentsOfFile:path];
  } else {
    path = [[NSBundle mainBundle] pathForResource:@"JSHTCPServer" ofType:@"plist"];
    shopsInfo = [NSDictionary dictionaryWithContentsOfFile:path];
  }
  return shopsInfo;
}

+ (void)saveTCPServer:(NSDictionary *)tcpServer {
  NSString *path = [[self documentDirectory] stringByAppendingPathComponent:@"JSHTCPServer.plist"];
  [tcpServer writeToFile:path atomically:YES];
}

@end
