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
    self.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    self.responseSerializer = [[AFJSONResponseSerializer alloc] init];
  }
  return self;
}


#pragma mark - Public

- (NSString *)domain {
  return kJavaBaseURL;
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

#pragma mark - 查询所有的酒店列表
- (void)getShopListWithPage:(NSString *)page size:(NSString *)size success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * string = [NSString stringWithFormat:@"shop/list/%d/%d",page.intValue,size.intValue];
  [self GET:string parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    // NSLog(@"酒店列表%@", [responseObject description]);
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
    // NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}


#pragma mark - 获取用户订单状态消息
- (void)getOrderWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary * dic = @{@"token":[self token],@"userid":@"5555ec48d6ed3"};
  
  [self POST:@"messages/orders" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    //NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

#pragma mark - 根据商户编号查询商户
- (void)accordingMerchantNumberInquiryMerchantWithShopID:(NSString *)shopID success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSString * string = [NSString stringWithFormat:@"shop/getshop/%@",shopID];
  [self GET:string parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    //NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

@end
