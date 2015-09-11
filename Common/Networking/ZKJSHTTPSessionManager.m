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
#import "CocoaLumberjack.h"
#import "JSHAccountManager.h"

static const DDLogLevel ddLogLevel = DDLogLevelInfo;

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
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 注册
- (void)userSignUpWithPhone:(NSString *)phone openID:(NSString *)openID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *phoneOS = [[UIDevice currentDevice] systemVersion];  // 系统版本
  NSString *os = @"3";  // WEB'1' 安卓'2' 苹果'3' 其他'4'
  NSString *userStatus = @"2";  // 用户状态 注册用户为 '2', 快捷匿名用户为 '3'
  NSString *deviceUUID = [[UIDevice currentDevice] identifierForVendor].UUIDString;  // 手机唯一标示
  
  [self POST:@"user/reg" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[phone dataUsingEncoding:NSUTF8StringEncoding] name:@"phone"];
    if (openID) {
      [formData appendPartWithFormData:[openID dataUsingEncoding:NSUTF8StringEncoding] name:@"openID"];
    }
    [formData appendPartWithFormData:[phoneOS dataUsingEncoding:NSUTF8StringEncoding] name:@"phone_os"];
    [formData appendPartWithFormData:[os dataUsingEncoding:NSUTF8StringEncoding] name:@"os"];
    [formData appendPartWithFormData:[userStatus dataUsingEncoding:NSUTF8StringEncoding] name:@"userstatus"];
    [formData appendPartWithFormData:[deviceUUID dataUsingEncoding:NSUTF8StringEncoding] name:@"bluetooth_key"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 判断用户手机和微信第三方id是否已经注册过
- (void)verifyIsRegisteredWithID:(NSString *)__id success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/getuser?id=%@", __id];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 登出
- (void)logoutWithUserID:(NSString *)userID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/logout?userid=%@", userID];
  [self POST:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 检查重复手机
- (void)checkDuplicatePhoneWithPhone:(NSString *)phone success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/getphone?phone=%@", phone];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 修改帐号密码
- (void)changeAccountPasswordWithPhone:(NSString *)phone newPassword:(NSString *)newPassword success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/chg" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[phone dataUsingEncoding:NSUTF8StringEncoding] name:@"phone"];
    [formData appendPartWithFormData:[[newPassword MD5String] dataUsingEncoding:NSUTF8StringEncoding] name:@"password"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 修改用户信息
- (void)updateUserInfoWithUserID:(NSString *)userID token:(NSString *)token username:(NSString *)username realname:(NSString *)realname imageData:(NSData *)imageData imageName:(NSString *)imageName sex:(NSString *)sex company:(NSString *)company occupation:(NSString *)occupation email:(NSString *)email tagopen:(NSNumber *)tagopen success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  [dic setObject:userID forKey:@"userid"];
  [dic setObject:token forKey:@"token"];
  if (username) {
    [dic setObject:username forKey:@"username"];
  }
  if (realname) {
    [dic setObject:realname forKey:@"realname"];
  }
  if (sex) {
    [dic setObject:sex forKey:@"sex"];
  }
  if (company) {
    [dic setObject:company forKey:@"company"];
  }
  if (occupation) {
    [dic setObject:occupation forKey:@"occupation"];
  }
  if (email) {
    [dic setObject:email forKey:@"email"];
  }
  if (tagopen) {
    [dic setObject:tagopen forKey:@"tagopen"];
  }
  [self POST:@"user/upload" parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    if (imageData) {
      [formData appendPartWithFileData:imageData name:@"UploadForm[file]" fileName:imageName mimeType:@"image/jpeg"];
    }
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

- (void)updateUserInfoWithParaDic:(NSDictionary *)paraDic success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:paraDic];
  [dic setObject:[JSHAccountManager sharedJSHAccountManager].userid forKey:@"userid"];
  [dic setObject:[JSHAccountManager sharedJSHAccountManager].token forKey:@"token"];
  [self POST:@"user/upload" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 获取默认发票
- (void)getDefaultInvoiceSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *userid = [JSHAccountManager sharedJSHAccountManager].userid;
  NSString *token = [JSHAccountManager sharedJSHAccountManager].token;
  NSDictionary *dic = @{@"userid" : userid,
                        @"token" : token,
                        @"set" : @1
                        };
    [self POST:@"user/fplist" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
      DDLogInfo(@"%@", [responseObject description]);
      success(task, responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      DDLogInfo(@"%@", error.description);
      failure(task, error);
    }];
}

// 获取发票列表
- (void)getInvoiceListSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *userid = [JSHAccountManager sharedJSHAccountManager].userid;
  NSString *token = [JSHAccountManager sharedJSHAccountManager].token;
  NSDictionary *dic = @{@"userid" : userid,
                        @"token" : token,
                        @"set" : @0
                        };
  [self POST:@"user/fplist" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 添加发票
- (void)addInvoiceWithTitle:(NSString *)title isDefault:(BOOL)isDefault Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *userid = [JSHAccountManager sharedJSHAccountManager].userid;
  NSString *token = [JSHAccountManager sharedJSHAccountManager].token;
  NSDictionary *dic = @{@"userid" : userid,
                        @"token" : token,
                        @"invoice_title" : title,
                        @"is_default" : [NSNumber numberWithBool:isDefault]
                        };
  [self POST:@"user/fpadd" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 修改发票
- (void)modifyInvoiceWithInvoiceid:(NSString *)invoiceid title:(NSString *)title isDefault:(BOOL)isDefault Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *userid = [JSHAccountManager sharedJSHAccountManager].userid;
  NSString *token = [JSHAccountManager sharedJSHAccountManager].token;
  NSDictionary *dic = @{@"userid" : userid,
                        @"token" : token,
                        @"id" : invoiceid,
                        @"set" : @2,
                        @"invoice_title" : title,
                        @"is_default" : [NSNumber numberWithBool:isDefault]
                        };
  [self POST:@"user/fpupdate" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 删除发票
- (void)deleteInvoiceWithInvoiceid:(NSString *)invoiceid Success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
  NSString *userid = [JSHAccountManager sharedJSHAccountManager].userid;
  NSString *token = [JSHAccountManager sharedJSHAccountManager].token;
  NSDictionary *dic = @{@"userid" : userid,
                        @"token" : token,
                        @"id" : invoiceid,
                        @"set" : @3
                        };
  [self POST:@"user/fpupdate" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
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
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 取得指定条件的商家列表信息
- (void)getAllShopInfoWithPage:(NSInteger)page key:(NSString *)key isDesc:(BOOL)isDesc success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *order = isDesc ? @"desc" : @"asc";
  NSString *urlString;
  if (key == nil) {
    urlString = [NSString stringWithFormat:@"user/selectshop?web=0&page=%ld", (long)page];
  }else {
    urlString = [NSString stringWithFormat:@"user/selectshop?web=0&page=%ld&key=%@&desc=%@", (long)page, key, order];
  }
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 取得商家信息
- (void)getShopInfo:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/selectshop?&shopid=%@&web=0", shopID];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 取得商家评论信息
- (void)getShopCommentsWithShopID:(NSString *)shopID start:(NSInteger)start page:(NSInteger)page key:(NSString *)key isDesc:(BOOL)isDesc success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *order = isDesc ? @"desc" : @"asc";
  NSString *urlString = [NSString stringWithFormat:@"user/comment?web=0&shopid=%@&stat=%ld&page=%ld&key=%@&desc=%@", shopID, (long)start, (long)page, key, order];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

//取得已有标签
- (void)getSelectedTagsWithID:(NSString *)userID token:(NSString *)token success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSString *urlString = [NSString stringWithFormat:@"tags/user?userid=%@&token=%@", userID, token];
    [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
      DDLogInfo(@"%@", [responseObject description]);
      success(task, responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      DDLogInfo(@"%@", error.description);
      failure(task, error);
    }];
}

// 获取随机标签池
- (void)getRandomTagsWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [self GET:@"tags/show" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
      DDLogInfo(@"%@", [responseObject description]);
      success(task, responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      DDLogInfo(@"%@", error.description);
      failure(task, error);
    }];
}

// 上传用户标签
- (void)updateTagsWithUserID:(NSString *)userID token:(NSString *)token tags:(NSString *)tags success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"tags/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[tags dataUsingEncoding:NSUTF8StringEncoding] name:@"tagid"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 获取订单详情
- (void)getOrderWithReservation_no:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[JSHAccountManager sharedJSHAccountManager].userid forKey:@"userid"];
    [dic setObject:[JSHAccountManager sharedJSHAccountManager].token forKey:@"token"];
//    [dic setObject: forKey:@"userid"];
//    [dic setObject:@"I1Ae4us4ssrwsWIg" forKey:@"token"];
    [dic setObject:reservation_no forKey:@"reservation_no"];
//    [dic setObject:[NSNumber numberWithInt:shopid] forKey:@"shopid"];
    [self POST:@"order/show" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogInfo(@"%@", [responseObject description]);
        success(task, responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogInfo(@"%@", error.description);
        failure(task, error);
    }];
}

// 修改订单
- (void)modifyOrderWithReservation_no:(NSString *)reservation_no param:(NSDictionary *)param success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:param];
    [dic setObject:[JSHAccountManager sharedJSHAccountManager].userid forKey:@"userid"];
    [dic setObject:[JSHAccountManager sharedJSHAccountManager].token forKey:@"token"];
    //    [dic setObject: forKey:@"userid"];
    //    [dic setObject:@"I1Ae4us4ssrwsWIg" forKey:@"token"];
    [dic setObject:@1 forKey:@"status"];
    [dic setObject:reservation_no forKey:@"reservation_no"];
    //    [dic setObject:[NSNumber numberWithInt:shopid] forKey:@"shopid"];
    [self POST:@"order/update" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
      DDLogInfo(@"%@", [responseObject description]);
      success(task, responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      DDLogInfo(@"%@", error.description);
      failure(task, error);
    }];
}
// 取消订单
- (void)cancelOrderWithReservation_no:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[JSHAccountManager sharedJSHAccountManager].userid forKey:@"userid"];
    [dic setObject:[JSHAccountManager sharedJSHAccountManager].token forKey:@"token"];
    [dic setObject:@0 forKey:@"status"];
    [dic setObject:reservation_no forKey:@"reservation_no"];
    //    [dic setObject:[NSNumber numberWithInt:shopid] forKey:@"shopid"];
    [self POST:@"order/update" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
      DDLogInfo(@"%@", [responseObject description]);
      success(task, responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      DDLogInfo(@"%@", error.description);
      failure(task, error);
    }];
}
// 获取指定条件商品列表
- (void)getShopGoodsWithShopID:(NSString *)shopID page:(NSInteger)page categoryID:(NSString *)categoryID key:(NSString *)key success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *category = categoryID ? [NSString stringWithFormat:@"&cat_id=%@", categoryID] : @"";
  NSString *orderBy = key ? [NSString stringWithFormat:@"&by=%@", key] : @"";
  NSString *urlString = [NSString stringWithFormat:@"user/goods?shopid=%@&page=%ld%@%@", shopID, (long)page, category, orderBy];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}
// 获取所有商品列表
- (void)getShopGoodsPage:(NSInteger)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
//    NSString *urlString = [NSString stringWithFormat:@"user/goods?shopid=%@&page=%ld", shopID, (long)page];
    NSString *urlString = [NSString stringWithFormat:@"user/goods?page=%ld", (long)page];
    [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}


// 获取商品
- (void)getShopGoodsWithShopID:(NSString *)shopID goodsID:(NSString *)goodsID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/goods?shopid=%@&goodsid=%@", shopID, goodsID];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 获取商品分类
- (void)getShopGoodsCategoryWith:(NSString *)categoryID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/category/%@", categoryID];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 上传酒店订单
- (void)postBookingInfoWithUserID:(NSString *)userID token:(NSString *)token shopID:(NSString *)shopID goodsID:(NSString *)goodsID guest:(NSString *)guest guestPhone:(NSString *)guestPhone roomNum:(NSString *)roomNum arrivalDate:(NSString *)arrivalDate departureDate:(NSString *)departureDate roomType:(NSString *)roomType roomRate:(NSString *)roomRate remark:(NSString *)remark success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/postvipre" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 订单列表
- (void)getOrderListWithUserID:(NSString *)userID token:(NSString *)token page:(NSString *)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/order" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[page dataUsingEncoding:NSUTF8StringEncoding] name:@"page"];
    [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] name:@"set"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 最近一张订单
- (void)getLatestOrderWithUserID:(NSString *)userID token:(NSString *)token success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/order" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[@"-1" dataUsingEncoding:NSUTF8StringEncoding] name:@"page"];
    [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] name:@"set"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 取消订单
- (void)cancelOrderWithUserID:(NSString *)userID token:(NSString *)token reservation_no:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/order" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[reservation_no dataUsingEncoding:NSUTF8StringEncoding] name:@"reservation_no"];
    [formData appendPartWithFormData:[@"0" dataUsingEncoding:NSUTF8StringEncoding] name:@"set"];
    [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] name:@"status"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 删除订单
- (void)deleteOrderWithUserID:(NSString *)userID token:(NSString *)token reservation_no:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/order" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[reservation_no dataUsingEncoding:NSUTF8StringEncoding] name:@"reservation_no"];
    [formData appendPartWithFormData:[@"0" dataUsingEncoding:NSUTF8StringEncoding] name:@"set"];
    [formData appendPartWithFormData:[@"5" dataUsingEncoding:NSUTF8StringEncoding] name:@"status"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 提交轨迹
- (void)postGPSWithUserID:(NSString *)userID token:(NSString *)token longitude:(NSString *)longitude latitude:(NSString *)latitude traceTime:(NSString *)traceTime success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/gpsadd" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[longitude dataUsingEncoding:NSUTF8StringEncoding] name:@"map_longitude"];
    [formData appendPartWithFormData:[latitude dataUsingEncoding:NSUTF8StringEncoding] name:@"map_latitude"];
    [formData appendPartWithFormData:[traceTime dataUsingEncoding:NSUTF8StringEncoding] name:@"trace_time"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

// 获取入住人列表
- (void)getGuestListSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  [dic setObject:[JSHAccountManager sharedJSHAccountManager].userid forKey:@"userid"];
  [dic setObject:[JSHAccountManager sharedJSHAccountManager].token forKey:@"token"];
  [self POST:@"order/createlist" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}
// 新增入住人
- (void)addGuestWithParam:(NSDictionary *)param success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:param];
  [dic setObject:[JSHAccountManager sharedJSHAccountManager].userid forKey:@"userid"];
  [dic setObject:[JSHAccountManager sharedJSHAccountManager].token forKey:@"token"];
  [self POST:@"order/useradd" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}
@end
