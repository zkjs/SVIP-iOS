
//  JSHAccount.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/6/6.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHAccountManager.h"

@interface JSHAccountManager ()

@property (nonatomic, copy) NSUserDefaults *defaults;

@end

@implementation JSHAccountManager

+ (JSHAccountManager *)sharedJSHAccountManager {
  static JSHAccountManager *sharedJSHAccountManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedJSHAccountManager = [[self alloc] init];
  });
  return sharedJSHAccountManager;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.zkjinshi.svip"];
    _userid = [_defaults objectForKey:@"userid"];
    _token = [_defaults objectForKey:@"token"];
  }
  return self;
}

- (void)saveAccountWithDic:(NSDictionary *)dic
{
  _userid = dic[@"userid"];
  _token = dic[@"token"];
  [_defaults setObject:_userid forKey:@"userid"];
  [_defaults setObject:_token forKey:@"token"];
  [_defaults synchronize];
}

@end
