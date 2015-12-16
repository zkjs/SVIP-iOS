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
#import "SVIP-Swift.h"

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

#pragma mark - Private

- (NSString *)userID {
  return [AccountManager sharedInstance].userID;
}

- (NSString *)token {
  return [AccountManager sharedInstance].token;
}

- (NSString *)userName {
  return [AccountManager sharedInstance].userName;
}

- (NSString *)phone {
  return [AccountManager sharedInstance].phone;
}

- (BOOL)isValidTokenWithObject:(id)responseObject {
  if ([responseObject isKindOfClass:[NSDictionary class]] &&
      responseObject[@"set"] &&
      [responseObject[@"set"] boolValue] == NO &&
      [responseObject[@"err"] integerValue] == 400) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveInvalidToken)]) {
      [self.delegate didReceiveInvalidToken];
      return NO;
    }
  }
  return YES;
}

#pragma mark - 获取Beacon列表
- (void)getBeaconRegionListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self GET:@"user/location" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 注册
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
    [formData appendPartWithFormData:[[NSString stringWithFormat:@"ios%@", phoneOS] dataUsingEncoding:NSUTF8StringEncoding] name:@"phone_os"];
    [formData appendPartWithFormData:[os dataUsingEncoding:NSUTF8StringEncoding] name:@"os"];
    [formData appendPartWithFormData:[userStatus dataUsingEncoding:NSUTF8StringEncoding] name:@"userstatus"];
    [formData appendPartWithFormData:[deviceUUID dataUsingEncoding:NSUTF8StringEncoding] name:@"bluetooth_key"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 判断用户手机和微信第三方id是否已经注册过
- (void)verifyIsRegisteredWithID:(NSString *)__id success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/getuser?id=%@", __id];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"这是登录信息%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 登出
- (void)logoutWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/logout?userid=%@", [self userID]];
  [self POST:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
  //  DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 检查重复手机
- (void)checkDuplicatePhoneWithPhone:(NSString *)phone success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/getphone?phone=%@", phone];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 修改帐号密码
- (void)changeAccountPasswordWithPhone:(NSString *)phone newPassword:(NSString *)newPassword success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/chg" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[phone dataUsingEncoding:NSUTF8StringEncoding] name:@"phone"];
    [formData appendPartWithFormData:[[newPassword MD5String] dataUsingEncoding:NSUTF8StringEncoding] name:@"password"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 修改用户信息
- (void)updateUserInfoWithUsername:(NSString *)username realname:(NSString *)realname imageData:(NSData *)imageData imageName:(NSString *)imageName sex:(NSString *)sex company:(NSString *)company occupation:(NSString *)occupation email:(NSString *)email tagopen:(NSNumber *)tagopen success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  [dic setObject:[self userID] forKey:@"userid"];
  [dic setObject:[self token] forKey:@"token"];
  if (username) {
    [dic setObject:username forKey:@"username"];
  }
  if (realname) {
    [dic setObject:realname forKey:@"real_name"];
  }
  if (sex) {
    if ([sex isEqual:@"男"]) {
      [dic setObject:@"1" forKey:@"sex"];
    } else {
      [dic setObject:@"0" forKey:@"sex"];
    }
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
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

- (void)updateUserInfoWithParaDic:(NSDictionary *)paraDic success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:paraDic];
  [dic setObject:[self userID] forKey:@"userid"];
  [dic setObject:[self token] forKey:@"token"];
  [self POST:@"user/upload" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    };
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 获取默认发票
- (void)getDefaultInvoiceWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *userid = [JSHAccountManager sharedJSHAccountManager].userid;
  NSString *token = [JSHAccountManager sharedJSHAccountManager].token;
  NSDictionary *dic = @{@"userid" : userid,
                        @"token" : token,
                        @"set" : @1
                        };
  [self POST:@"user/fplist" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 获取发票列表
- (void)getInvoiceListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary *dic = @{@"userid" : [self userID],
                        @"token" : [self token],
                        @"set" : @0
                        };
  [self POST:@"user/fplist" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 添加发票
- (void)addInvoiceWithTitle:(NSString *)title isDefault:(BOOL)isDefault Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary *dic = @{@"userid" : [self userID],
                        @"token" : [self token],
                        @"invoice_title" : title,
                        @"is_default" : [NSNumber numberWithBool:isDefault]
                        };
  [self POST:@"user/fpadd" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 修改发票
- (void)modifyInvoiceWithInvoiceid:(NSString *)invoiceid title:(NSString *)title isDefault:(BOOL)isDefault Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary *dic = @{@"userid" : [self userID],
                        @"token" : [self token],
                        @"id" : invoiceid,
                        @"set" : @2,
                        @"invoice_title" : title,
                        @"is_default" : [NSNumber numberWithBool:isDefault]
                        };
  [self POST:@"user/fpupdate" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 删除发票
- (void)deleteInvoiceWithInvoiceid:(NSString *)invoiceid Success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
  NSDictionary *dic = @{@"userid" : [self userID],
                        @"token" : [self token],
                        @"id" : invoiceid,
                        @"set" : @3
                        };
  [self POST:@"user/fpupdate" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 取得用户头像
- (UIImage *)getUserProfile {
  NSString *urlString = [NSString stringWithFormat:@"%@uploads/users/%@.jpg", kBaseURL, [self userID]];
  NSData *imageData = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:urlString]];
  UIImage *image = [[UIImage alloc] initWithData:imageData];
  return image;
}

#pragma mark - 取得用户信息
- (void)getUserInfoWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/select?&userid=%@&token=%@", [self userID], [self token]];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 取得指定条件的商家列表信息
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
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 取得商家信息
- (void)getShopInfo:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/selectshop?&shopid=%@&web=0", shopID];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 取得商家评论信息
- (void)getShopCommentsWithShopID:(NSString *)shopID start:(NSInteger)start page:(NSInteger)page key:(NSString *)key isDesc:(BOOL)isDesc success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *order = isDesc ? @"desc" : @"asc";
  NSString *urlString = [NSString stringWithFormat:@"user/comment?web=0&shopid=%@&stat=%ld&page=%ld&key=%@&desc=%@", shopID, (long)start, (long)page, key, order];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 取得已有标签
- (void)getSelectedTagsWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
  NSString *urlString = [NSString stringWithFormat:@"tags/user?userid=%@&token=%@", [self userID], [self token]];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 获取随机标签池
- (void)getRandomTagsWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
  [self GET:@"tags/show" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 上传用户标签
- (void)updateTagsWithTags:(NSString *)tags success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"tags/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[tags dataUsingEncoding:NSUTF8StringEncoding] name:@"tagid"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 获取订单详情
- (void)getOrderWithReservation_no:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  [dic setObject:[self userID] forKey:@"userid"];
  [dic setObject:[self token] forKey:@"token"];
  [dic setObject:reservation_no forKey:@"reservation_no"];
  [self POST:@"order/show" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 修改订单
- (void)modifyOrderWithReservation_no:(NSString *)reservation_no param:(NSDictionary *)param success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:param];
  [dic setObject:[self userID] forKey:@"userid"];
  [dic setObject:[self token] forKey:@"token"];
  [dic setObject:@2 forKey:@"status"];
  [dic setObject:reservation_no forKey:@"reservation_no"];
  [self POST:@"order/update2" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 取消订单
- (void)cancelOrderWithReservation_no:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  [dic setObject:[self userID] forKey:@"userid"];
  [dic setObject:[self token] forKey:@"token"];
  [dic setObject:@1 forKey:@"status"];
  [dic setObject:reservation_no forKey:@"reservation_no"];
  [self POST:@"order/update2" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 获取指定商家的商品列表
- (void)getShopGoodsListWithShopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"order/goods?shopid=%@", shopID];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 获取所有商品列表
- (void)getShopGoodsPage:(NSInteger)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/goods?page=%ld", (long)page];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 获取商品
- (void)getShopGoodsWithShopID:(NSString *)shopID goodsID:(NSString *)goodsID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/goods?shopid=%@&goodsid=%@", shopID, goodsID];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 获取商品分类
- (void)getShopGoodsCategoryWith:(NSString *)categoryID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString *urlString = [NSString stringWithFormat:@"user/category/%@", categoryID];
  [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 上传酒店订单
- (void)postBookingInfoWithShopID:(NSString *)shopID goodsID:(NSString *)goodsID guest:(NSString *)guest guestPhone:(NSString *)guestPhone roomNum:(NSString *)roomNum arrivalDate:(NSString *)arrivalDate departureDate:(NSString *)departureDate roomType:(NSString *)roomType roomRate:(NSString *)roomRate remark:(NSString *)remark success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/postvipre" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
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
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 订单列表
- (void)getOrderListWithPage:(NSString *)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"order/showlist" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[page dataUsingEncoding:NSUTF8StringEncoding] name:@"page"];
    [formData appendPartWithFormData:[@"0,2,3,4" dataUsingEncoding:NSUTF8StringEncoding] name:@"status"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
  // DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 历史订单列表
- (void)getOrderHistoryListWithPage:(NSString *)page success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"order/v10list" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[page dataUsingEncoding:NSUTF8StringEncoding] name:@"page"];
    [formData appendPartWithFormData:[@"0,2,3,4" dataUsingEncoding:NSUTF8StringEncoding] name:@"status"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    NSLog(@"==%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 最近一张订单
- (void)getLatestOrderWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"order/last" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
   // DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 取消订单
- (void)cancelOrderWithReservationNO:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/order" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[reservation_no dataUsingEncoding:NSUTF8StringEncoding] name:@"reservation_no"];
    [formData appendPartWithFormData:[@"0" dataUsingEncoding:NSUTF8StringEncoding] name:@"set"];
    [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] name:@"status"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 删除订单
- (void)deleteOrderWithReservationNO:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  [dic setObject:[self userID] forKey:@"userid"];
  [dic setObject:[self token] forKey:@"token"];
  [dic setObject:@5 forKey:@"status"];
  [dic setObject:reservation_no forKey:@"reservation_no"];
  [self POST:@"order/update2" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 提交轨迹
- (void)postGPSWithLongitude:(NSString *)longitude latitude:(NSString *)latitude traceTime:(NSString *)traceTime success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/gpsadd" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[longitude dataUsingEncoding:NSUTF8StringEncoding] name:@"map_longitude"];
    [formData appendPartWithFormData:[latitude dataUsingEncoding:NSUTF8StringEncoding] name:@"map_latitude"];
    [formData appendPartWithFormData:[traceTime dataUsingEncoding:NSUTF8StringEncoding] name:@"trace_time"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 获取入住人列表
- (void)getGuestListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  [dic setObject:[self userID] forKey:@"userid"];
  [dic setObject:[self token] forKey:@"token"];
  [self POST:@"order/createlist" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 新增入住人
- (void)addGuestWithParam:(NSDictionary *)param success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:param];
  [dic setObject:[self userID] forKey:@"userid"];
  [dic setObject:[self token] forKey:@"token"];
  [self POST:@"order/useradd" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 客户根据邀请码查询服务员
- (void)getSaleInfoWithCode:(NSString *)code success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"invitation/getcode" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[code dataUsingEncoding:NSUTF8StringEncoding] name:@"code"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 超级身份输入\绑定 邀请码动作
- (void)pairInvitationCodeWith:(NSString *)code salesID:(NSString *)salesID phone:(NSString *)phone salesName:(NSString *)salesName salesPhone:(NSString *)salesPhone shopID:(NSString *)shopID shopName:(NSString *)shopName success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"invitation/bdcode" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[[self userName] dataUsingEncoding:NSUTF8StringEncoding] name:@"username"];
    [formData appendPartWithFormData:[phone dataUsingEncoding:NSUTF8StringEncoding] name:@"phone"];
    [formData appendPartWithFormData:[code dataUsingEncoding:NSUTF8StringEncoding] name:@"code"];
    [formData appendPartWithFormData:[salesName dataUsingEncoding:NSUTF8StringEncoding] name:@"sales_name"];
    [formData appendPartWithFormData:[salesPhone dataUsingEncoding:NSUTF8StringEncoding] name:@"sales_phone"];
    [formData appendPartWithFormData:[shopName dataUsingEncoding:NSUTF8StringEncoding] name:@"shop_name"];
    [formData appendPartWithFormData:[salesID dataUsingEncoding:NSUTF8StringEncoding] name:@"user_salesid"];
    [formData appendPartWithFormData:[shopID dataUsingEncoding:NSUTF8StringEncoding] name:@"shopid"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 提交订单评价
- (void)submitEvaluationWithScore:(NSString *)score content:(NSString *)content reservation_no:(NSString *)reservation_no success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"comment/add" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[score dataUsingEncoding:NSUTF8StringEncoding] name:@"score"];
    [formData appendPartWithFormData:[content dataUsingEncoding:NSUTF8StringEncoding] name:@"content"];
    [formData appendPartWithFormData:[reservation_no dataUsingEncoding:NSUTF8StringEncoding] name:@"reservation_no"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 获取推送的广告
- (void)getAdvertisementListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self GET:@"ad/list" parameters:nil success:^(NSURLSessionDataTask *  task, id responseObject) {
//    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *  task, NSError *  error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 查看商家客服列表带专属客服
- (void)getMerchanCustomerServiceListWithShopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/mysemplist" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[shopID dataUsingEncoding:NSUTF8StringEncoding] name:@"shopid"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
   // DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - ping++支付请求
- (void)pingPayWithDic:(NSDictionary * )param success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:param];
 
  [self POST:@"ping/paycharge" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];

}

#pragma mark - ping++发起退款申请
- (void)pingPayrefundWithID:(NSString *) chargeID amount:(NSString *)amount description:(NSString *)description success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"pay/payrefund" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[chargeID dataUsingEncoding:NSUTF8StringEncoding] name:@"id"];
    [formData appendPartWithFormData:[amount dataUsingEncoding:NSUTF8StringEncoding] name:@"amount"];
    [formData appendPartWithFormData:[description dataUsingEncoding:NSUTF8StringEncoding] name:@"description"];
   } success:^(NSURLSessionDataTask *task, id responseObject) {
    //    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 查询用户(服务员)简单信息
- (void)getUserInfoWithChatterID:(NSString *)chatterID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"v10/user" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    [formData appendPartWithFormData:[chatterID dataUsingEncoding:NSUTF8StringEncoding] name:@"find_userid"];
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    //    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
}

#pragma mark - 添加/删除/显示好友
- (void)managerFreindListWithFuid:(NSString *)fuid set:(NSString *)set success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    [self POST:@"user/friend" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
      [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
      [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
      [formData appendPartWithFormData:[fuid dataUsingEncoding:NSUTF8StringEncoding] name:@"fuid"];
       [formData appendPartWithFormData:[set dataUsingEncoding:NSUTF8StringEncoding] name:@"set"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
          DDLogInfo(@"%@", [responseObject description]);
      if ([self isValidTokenWithObject:responseObject]) {
        success(task, responseObject);
      }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      DDLogInfo(@"%@", error.description);
      failure(task, error);
    }];
  }

#pragma mark - 获取我的专属客服是否存在(邀请码是否激活)
- (void)InvitationCodeActivatedSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"user/mysemp" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFormData:[[self userID] dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
    [formData appendPartWithFormData:[[self token] dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
    
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];

}

#pragma mark -获取(涉及商家的)城市列表
- (void)getCityListSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self POST:@"arrive/citylist" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
  } success:^(NSURLSessionDataTask *task, id responseObject) {
    DDLogInfo(@"%@", [responseObject description]);
    if ([self isValidTokenWithObject:responseObject]) {
      success(task, responseObject);
    }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    DDLogInfo(@"%@", error.description);
    failure(task, error);
  }];
  
}


@end
