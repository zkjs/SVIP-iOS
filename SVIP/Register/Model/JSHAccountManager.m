
//  JSHAccount.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/6/6.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHAccountManager.h"

@implementation JSHAccountManager
single_implementation(JSHAccountManager)
- (instancetype)init
{
    self = [super init];
    if (self) {
        _userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
        _token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    }
    return self;
}
- (void)saveAccountWithDic:(NSDictionary *)dic
{
    _userid = dic[@"userid"];
    _token = dic[@"token"];
    [[NSUserDefaults standardUserDefaults] setObject:_userid forKey:@"userid"];
    [[NSUserDefaults standardUserDefaults] setObject:_token forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
