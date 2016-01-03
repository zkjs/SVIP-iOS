//
//  ZKJSJavaHTTPSessionManager.m
//  SuperService
//
//  Created by Hanton on 12/13/15.
//  Copyright © 2015 ZKJS. All rights reserved.
//

#import "ZKJSJavaHTTPSessionManager.h"

#import "NSString+ZKJS.h"
#import "SVIP-Swift.h"
#import "EaseMob.h"

@implementation ZKJSJavaHTTPSessionManager

#pragma mark - Initialization

+ (instancetype)sharedInstance {
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super initWithBaseURL:[[NSURL alloc] initWithString:kJavaBaseURL]];
  if (self) {
    self.requestSerializer = [[AFJSONRequestSerializer alloc] init];
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

#pragma mark - 区域位置变化通知
- (void)regionalPositionChangeNoticeWithUserID:(NSString *)userID locID:(NSString *)locID shopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary * dic = @{@"userid":userID,@"shopid":shopID,@"locid":locID};
  [self POST:@"arrive/notice" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    //NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

#pragma mark -获取同步的到店列表
- (void)getSynchronizedStoreListWithShopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * string = [NSString stringWithFormat:@"arrive/users/%@/%@/%@",shopID,[self userID],[self token]];
  [self GET:string parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    //NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

#pragma mark - 首页大图
- (void)getHomeImageWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self GET:@"firstpage/icons" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    //NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

#pragma mark - 根据城市名称查询酒店列表
- (void)getShopListWithCity:(NSString *)city page:(NSString *)page size:(NSString *)size Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * string = [NSString stringWithFormat:@"shop/list/%@/%@/%@",city,page,size];
  string = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//传中文汉字需要解码
  [self GET:string parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    // NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

#pragma mark - 查询所有的酒店列表(未登录时的)
- (void)getLoginOutShopListWithPage:(NSString *)page size:(NSString *)size success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * string = [NSString stringWithFormat:@"shop/list/%d/%d",page.intValue,size.intValue];
  [self GET:string parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
     //NSLog(@"酒店列表%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

#pragma mark - 查询所有的酒店列表
- (void)getShopListWithPage:(NSString *)page size:(NSString *)size success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * string = [NSString stringWithFormat:@"shop/list/user/%@/%d/%d",[self userID],page.intValue,size.intValue];
  [self GET:string parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    NSLog(@"酒店列表%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

#pragma mark - 获取推荐商家列表
- (void)getRecommendShopListWithCity:(NSString *)city  Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * string = [NSString stringWithFormat:@"shop/recommended/%@",city];
  string = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//传中文汉字需要解码
  [self GET:string parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
     //NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

#pragma mark - 获取用户推送消息(用户未登陆)
- (void)getPushInfoToUserWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self GET:@"messages/default" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
   //  NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}


#pragma mark - 获取用户订单状态消息
- (void)getOrderWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary * dic = @{@"token":[self token],@"userid":[self userID]};
  
  [self POST:@"messages/orders" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
   // NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

#pragma mark - 根据商户编号查询商户
- (void)accordingMerchantNumberInquiryMerchantWithShopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * string = [NSString stringWithFormat:@"shop/getshop/%@",shopID];
  [self GET:string parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
   // NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
  //  NSLog(@"%@", [error description]);
    failure(task, error);
  }];
}

#pragma mark - 根据电话查询用户
- (void)checkSalesWithPhone:(NSString *)phone Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * url = [NSString stringWithFormat:@"user/getuser/%@", phone];
  [self GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    // NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

#pragma mark - 根据酒店区域获取用户特权
- (void)getPrivilegeWithShopID:(NSString *)shopID locID:(NSString *)locID Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * url = [NSString stringWithFormat:@"user/privilege/%@/%@", shopID,locID];
  [self GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
  //   NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

# pragma mark - 获取订单列表
- (void)getOrderListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * url = [NSString stringWithFormat:@"order/list/%@/1/10", [self userID]];
  [self GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
       NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

# pragma mark - 获取订单详情
- (void)getOrderDetailWithOrderNo:(NSString *)orderno Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * url = [NSString stringWithFormat:@"order/get/%@", orderno];
  [self GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
     NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

# pragma mark - 订单新增
- (void)addOrderWithCategory:(NSString *)category data:(NSDictionary *)data Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * str = [ZKJSTool convertJSONStringFromDictionary:data];
  NSData *plainTextData = [str dataUsingEncoding:NSUTF8StringEncoding];
  NSString *base64String = [plainTextData base64EncodedStringWithOptions:0];
  NSDictionary * dic = @{@"category":category,@"data":base64String};
  [self POST:@"order/add" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
    NSLog(@"%@", [error description]);
  }];
 
//  [self POST:@"order/add" parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//    [formData appendPartWithFormData:[category dataUsingEncoding:NSUTF8StringEncoding] name:@"category"];
//    [formData appendPartWithFormData:[base64String dataUsingEncoding:NSUTF8StringEncoding] name:@"data"];
//    
//  } success:^(NSURLSessionDataTask *task, id responseObject) {
//    NSLog(@"%@", [responseObject description]);
//    success(task, responseObject);
//  } failure:^(NSURLSessionDataTask *task, NSError *error) {
//    NSLog(@"%@", error.description);
//    failure(task, error);
//  }];

}
# pragma mark - 获取商家详情
- (void)getOrderDetailWithShopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * url = [NSString stringWithFormat:@"shop/get/%@", shopID];
  [self GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

# pragma mark - 订单确认
- (void)confirmOrderWithOrderNo:(NSString *)orderno Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary * dic = @{@"orderno":orderno};
  [self POST:@"order/confirm" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

# pragma mark - 取消订单
- (void)cancleOrderWithOrderNo:(NSString *)orderno Success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary * dic = @{@"orderno":orderno};
  [self POST:@"order/cancel" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

@end
