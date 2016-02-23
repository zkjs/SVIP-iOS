//
//  ZKJSLocationHTTPSessionManager.m
//  SVIP
//
//  Created by AlexBang on 16/2/23.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

#import "ZKJSLocationHTTPSessionManager.h"
#import "NSString+ZKJS.h"
#import "SVIP-Swift.h"
#import "EaseMob.h"


@implementation ZKJSLocationHTTPSessionManager
+ (instancetype)sharedInstance {
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super initWithBaseURL:[[NSURL alloc] initWithString:kBaseLocationURL]];
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

#pragma mark - 推送/更新室内位置
- (void)regionalPositionChangeNoticeWithMajor:(NSString *)major locID:(NSString *)locID minior:(NSString *)minior uuid:(NSString *)uuid sensorid:(NSString *)sensorid timestamp:(NSNumber*)timestamp success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary * dic = @{@"major":major,@"minior":minior,@"locid":locID,@"uuid":uuid,@"sensorid":sensorid,@"timestamp":timestamp};
  [self POST:@"application/json" parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    //    NSLog(@"%@", responseObject);
    success(task, responseObject);
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"%@", [error description]);
    failure(task, error);
  }];
}

@end
