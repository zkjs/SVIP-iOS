//
//  ZKJSHTTPSessionManager.m
//  HotelVIP
//
//  Created by Hanton on 6/1/15.
//  Copyright (c) 2015 ZKJS. All rights reserved.
//

#import "ZKJSHTTPSessionManager.h"
#import "NSString+ZKJS.h"
#import "Networkcfg.h"

@interface ZKJSHTTPSessionManager ()

@end

@implementation ZKJSHTTPSessionManager

+ (instancetype)sharedInstance {
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super initWithBaseURL:[[NSURL alloc] initWithString:kBaseURL]];
  if (self) {
    self.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    self.responseSerializer = [[AFJSONResponseSerializer alloc] init];
  }
  return self;
}

// 获取Beacon列表
- (void)getBeaconRegionListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self GET:@"user/location" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 注册
- (void)userSignUpWithPhone:(NSString *)phone success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *phoneOS = [[UIDevice currentDevice] systemVersion];  // 系统版本
  NSString *latitude = @"23.12";  // 经度
  NSString *longitude = @"108.23";  // 纬度
  NSString *os = @"3";  // WEB'1' 安卓'2' 苹果'3' 其他'4'
  NSString *userStatus = @"2";  // 用户状态 注册用户为 '2', 快捷匿名用户为 '3'
  NSString *deviceUUID = [[UIDevice currentDevice] identifierForVendor].UUIDString;  // 手机唯一标示
  
  NSDictionary *RegForm = @{
                            @"phone": phone,
                            @"phone_os": phoneOS,
                            @"map_latitude": latitude,
                            @"map_longitude": longitude,
                            @"os": os,
                            @"userstatus": userStatus,
                            @"bluetooth_key": deviceUUID
                            };
  NSDictionary *parameters = @{
                               @"RegForm": RegForm
                               };
  [self POST:@"user/reg" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 登录
- (void)userLoginWithPhone:(NSString *)phone password:(NSString *)password rememberMe:(NSString *)rememberMe success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *passwordMD5 = [password MD5String];  // MD5密码
  NSString *phoneOS = [[UIDevice currentDevice] systemVersion];  // 系统版本
  NSString *latitude = @"23.12";  // 经度
  NSString *longitude = @"108.23";  // 纬度
  NSString *loginType = @"1";  // 登录类型 手机 默认1
  
  NSDictionary *LoginForm = @{
                            @"phone": phone,
                            @"password": passwordMD5,
                            @"rememberMe": rememberMe,
                            @"login_type": loginType,
                            @"phone_info": phoneOS,
                            @"map_latitude": latitude,
                            @"map_longitude": longitude
                            };
  NSDictionary *parameters = @{
                               @"LoginForm": LoginForm
                               };
  [self POST:@"user/login" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 匿名登录
- (void)visitorSignUpWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *os = @"3";  // WEB'1' 安卓'2' 苹果'3' 其他'4'
  NSString *userStatus = @"3";  // 用户状态 注册用户为 '2', 快捷匿名用户为 '3'
  NSString *deviceUUID = [[UIDevice currentDevice] identifierForVendor].UUIDString;  // 手机唯一标示
  
  NSDictionary *RegForm = @{
                           @"os": os,
                           @"userstatus": userStatus,
                           @"bluetooth_key": deviceUUID,
                           @"password": @""
                           };
  NSDictionary *parameters = @{
                              @"RegForm": RegForm
                              };
  [self POST:@"user/reg" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 登出
- (void)logoutWithUserID:(NSString *)userID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/logout?userid=%@", userID];
  [self POST:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 检查重复手机
- (void)checkDuplicatePhoneWithPhone:(NSString *)phone success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/reg?phone=%@", phone];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 修改帐号密码
- (void)changeAccountPasswordWithPhone:(NSString *)phone newPassword:(NSString *)newPassword success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary *UploadForm = @{
                              @"phone": phone,
                              @"password": [newPassword MD5String]
                              };
  NSDictionary *parameters = @{
                               @"UploadForm": UploadForm
                               };
  [self POST:@"user/chg" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 修改用户信息
- (void)updateUserInfoWithUserID:(NSString *)userID token:(NSString *)token userName:(NSString *)userName imageData:(NSData *)imageData imageName:(NSString *)imageName sex:(NSString *)sex company:(NSString *)company occupation:(NSString *)occupation success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    if (imageData) {
      [formData appendPartWithFileData:imageData name:@"UploadForm[file]" fileName:imageName mimeType:@"image/jpeg"];
    }
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"UploadForm[userid]"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"UploadForm[token]"];
    [formData appendPartWithFormData:[userName dataUsingEncoding:NSUTF8StringEncoding] name:@"UploadForm[username]"];
    if (sex) {
      [formData appendPartWithFormData:[sex dataUsingEncoding:NSUTF8StringEncoding] name:@"UploadForm[sex]"];
    }
    if (company) {
      [formData appendPartWithFormData:[company dataUsingEncoding:NSUTF8StringEncoding] name:@"UploadForm[preference]"];
    }
    if (occupation) {
      [formData appendPartWithFormData:[occupation dataUsingEncoding:NSUTF8StringEncoding] name:@"UploadForm[remark]"];
    }
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 取得用户头像
- (UIImage *)getUserProfileWithUserID:(NSString *)userID {
  NSString *urlString = [NSString stringWithFormat:@"%@uploads/users/%@.jpg", kBaseURL, userID];
  NSData *imageData = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:urlString]];
  UIImage *image = [[UIImage alloc] initWithData:imageData];
  return image;
}

// 取得用户信息
- (void)getUserInfo:(NSString *)userID token:(NSString *)token success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/select?&userid=%@&token=%@", userID, token];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 取得指定条件的商家信息
- (void)getAllShopInfoWithStart:(NSInteger)start page:(NSInteger)page key:(NSString *)key isDesc:(BOOL)isDesc success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *order = isDesc ? @"desc" : @"asc";
  NSString *urlString = [NSString stringWithFormat:@"shop/select?web=0&stat=%ld&page=%ld&key=%@&desc=%@", (long)start, (long)page, key, order];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 取得商家信息
- (void)getShopInfo:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"shop/select?&shopid=%@&web=0", shopID];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 取得商家评论信息
- (void)getShopCommentsWithShopID:(NSString *)shopID start:(NSInteger)start page:(NSInteger)page key:(NSString *)key isDesc:(BOOL)isDesc success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *order = isDesc ? @"desc" : @"asc";
  NSString *urlString = [NSString stringWithFormat:@"shop/comment?web=0&shopid=%@&stat=%ld&page=%ld&key=%@&desc=%@", shopID, (long)start, (long)page, key, order];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 取得标签格式1
/*
[
    {
        "id": "1",
        "fid": "0",
        "tag": "地点信息",
        "choes": "1"
    },
    {
        "id": "2",
        "fid": "1",
        "tag": "中国",
        "choes": null
    },....
]
*/
- (void)getTagsShowTreeWithCallback:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  
  [self GET:@"tags/showtree" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 取得标签格式2
/*
[
    {
        "id": "1",
        "fid": "0",
        "tag": "地点信息",
        "choes": "1",
        "children": [
            {
                "id": "2",
                "fid": "1",
                "tag": "中国",
                "choes": null,
                "children": [
                    {
                        "id": "4",
                        "fid": "2",
                        "tag": "大东北",
                        "choes": null,
                        "children": []
                    },...
            },
        父亲1
        父亲2
        children{
            }
        ....
]
*/
- (void)getTagsShowWithCallback:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  
  [self GET:@"tags/show" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 上传用户标签
- (void)updateTagsWithUserID:(NSString *)userID token:(NSString *)token tags:(NSString *)tags success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/puttags" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[tags dataUsingEncoding:NSUTF8StringEncoding] name:@"tags"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 获取商品列表
/*
- (void)getShopGoodsWithShopID:(NSString *)shopID page:(NSInteger)page categoryID:(NSString *)categoryID key:(NSString *)key success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *category = categoryID ? [NSString stringWithFormat:@"&cat_id=%@", categoryID] : @"";
  NSString *orderBy = key ? [NSString stringWithFormat:@"&by=%@", key] : @"";
  NSString *urlString = [NSString stringWithFormat:@"shop/goods?shopid=%@&page=%ld%@%@", shopID, (long)page, category, orderBy];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}
 */
- (void)getShopGoodsWithShopID:(NSString *)shopID page:(NSInteger)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"shop/goods?shopid=%@&page=%ld", shopID, (long)page];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}


// 获取商品
- (void)getShopGoodsWithShopID:(NSString *)shopID goodsID:(NSString *)goodsID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"shop/goods?shopid=%@&goodsid=%@", shopID, goodsID];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 获取商品分类
- (void)getShopGoodsCategoryWith:(NSString *)categoryID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"shop/category/%@", categoryID];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 上传酒店订单
- (void)postBookingInfoWithUserID:(NSString *)userID token:(NSString *)token shopID:(NSString *)shopID goodsID:(NSString *)goodsID guest:(NSString *)guest guestPhone:(NSString *)guestPhone roomNum:(NSString *)roomNum arrivalDate:(NSString *)arrivalDate departureDate:(NSString *)departureDate roomType:(NSString *)roomType roomRate:(NSString *)roomRate remark:(NSString *)remark success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"shop/postvipre" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[shopID dataUsingEncoding:NSUTF8StringEncoding] name:@"shopid"];
    [formData appendPartWithFormData:[goodsID dataUsingEncoding:NSUTF8StringEncoding] name:@"room_typeid"];
    [formData appendPartWithFormData:[guest dataUsingEncoding:NSUTF8StringEncoding] name:@"guest"];
    [formData appendPartWithFormData:[guestPhone dataUsingEncoding:NSUTF8StringEncoding] name:@"guesttel"];
    [formData appendPartWithFormData:[arrivalDate dataUsingEncoding:NSUTF8StringEncoding] name:@"arrival_date"];
    [formData appendPartWithFormData:[departureDate dataUsingEncoding:NSUTF8StringEncoding] name:@"departure_date"];
    [formData appendPartWithFormData:[roomNum dataUsingEncoding:NSUTF8StringEncoding] name:@"rooms"];
    [formData appendPartWithFormData:[roomType dataUsingEncoding:NSUTF8StringEncoding] name:@"room_type"];
    [formData appendPartWithFormData:[roomRate dataUsingEncoding:NSUTF8StringEncoding] name:@"room_rate"];
    [formData appendPartWithFormData:[remark dataUsingEncoding:NSUTF8StringEncoding] name:@"remark"];
    [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] name:@"set"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 订单列表
- (void)getOrderListWithUserID:(NSString *)userID token:(NSString *)token page:(NSString *)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"shop/order" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[page dataUsingEncoding:NSUTF8StringEncoding] name:@"page"];
    [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] name:@"set"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 取消订单
- (void)cancelOrderWithUserID:(NSString *)userID token:(NSString *)token orderID:(NSString *)orderID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"shop/order" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[orderID dataUsingEncoding:NSUTF8StringEncoding] name:@"id"];
    [formData appendPartWithFormData:[@"0" dataUsingEncoding:NSUTF8StringEncoding] name:@"set"];
    [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] name:@"status"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

// 删除订单
- (void)deleteOrderWithUserID:(NSString *)userID token:(NSString *)token orderID:(NSString *)orderID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"shop/order" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[orderID dataUsingEncoding:NSUTF8StringEncoding] name:@"id"];
    [formData appendPartWithFormData:[@"0" dataUsingEncoding:NSUTF8StringEncoding] name:@"set"];
    [formData appendPartWithFormData:[@"5" dataUsingEncoding:NSUTF8StringEncoding] name:@"status"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"%@", error.description);
    failure(task, error);
  }];
}

@end
