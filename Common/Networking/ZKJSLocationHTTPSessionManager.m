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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = serializer;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
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
- (void)regionalPositionChangeNoticeWithMajor:(NSString *)major minior:(NSString *)minior uuid:(NSString *)uuid sensorid:(NSString *)sensorid timestamp:(NSInteger)timestamp success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {

  ///////////////////////////////// token for test
  NSString *token = @"eyJhbGciOiJSUzUxMiJ9.eyJzdWIiOiJjXzU2YTZlN2I1NjM0OGMiLCJ0eXBlIjozLCJleHBpcmUiOjE0NTY4MjQxNDMxNjEsInNob3BpZCI6Ijg4ODgiLCJyb2xlcyI6W10sImZlYXR1cmUiOltdfQ.KSCmIWoc8Vuj7A03wFZhukgTlnq38WVLDgEbU7TO51pNTwuQ3Q36RSqMh4DOxlftkp7WLfvsn63KChZZGGZryoGEKZ8nOdVP4YCS7cJMN8WZKYt_3gdmt3l9eGAHa7d-EhqOpY-Qk0iZlHA_x134N-z9GFpE5sZJfaGllQ7W7pQ";
//  NSDictionary * dic = @{@"locid":major,@"major":major,@"minior":minior,@"uuid":uuid,@"sensorid":@"",@"timestamp":[NSNumber numberWithInt:timestamp],@"token":[self token]};
    NSDictionary * dic = @{@"locid":major,@"major":major,@"minor":minior,@"uuid":uuid,@"sensorid":@"",@"timestamp":[NSNumber numberWithLong:timestamp],@"token":token};

  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
  [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [serializer setValue:token forHTTPHeaderField:@"Token"];
  manager.requestSerializer = serializer;
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  [manager PUT:kBaseLocationURL parameters:dic
        success:^(AFHTTPRequestOperation *operation,id responseObject) {
          NSError *error;
          NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                               options:kNilOptions
                                                                 error:&error];
          NSLog(@"%@",json);
          if([json[@"res"] isEqualToNumber: @0]) {//success
            NSLog(@"beacon success");
          } else {//fail
            NSLog(@"beacon fail");
          }
        }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
          NSLog(@"beacon Error: %@", error);
        }];

}
#pragma mark - 推送/更新室外位置
- (void)GPSPositionChangeNoticeWithLatitude:(NSString *)latitude longitude:(NSString *)longitude altitude:(NSString *)altitude timestamp:(integer_t)timestamp success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
  NSDictionary * dic = @{@"latitude":@"1",@"longitude":@"2",@"altitude":@"3",@"token":@"head.payload.sign",@"timestamp":@1455870706863};
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
  [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  manager.requestSerializer = serializer;
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  [manager PUT:kJavaBaseGPSURL parameters:dic
       success:^(AFHTTPRequestOperation *operation,id responseObject) {
         
       }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
         NSLog(@"Error: %@", error);
       }];

}

@end
