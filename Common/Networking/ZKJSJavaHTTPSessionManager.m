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

#pragma mark - 首页大图
- (void)getHomeImageWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self GET:@"firstpage/icons" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    //NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}
#pragma mark - 查询所有的酒店列表
- (void)getShopListWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  [self GET:@"shop/list" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    success(task, responseObject);
    // NSLog(@"%@", [responseObject description]);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(task, error);
  }];
}

@end
