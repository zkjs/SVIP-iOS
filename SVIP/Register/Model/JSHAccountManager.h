//
//  JSHAccount.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/6/6.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSHAccountManager : NSObject

+ (JSHAccountManager *)sharedJSHAccountManager;

@property (readonly, nonatomic) NSString *userid;
@property (readonly, nonatomic) NSString *token;
@property (readonly, nonatomic) NSString *username;
@property (readonly, nonatomic) NSString *phone;
- (void)saveAccountWithDic:(NSDictionary *)dic;
- (void)saveUserName:(NSString *)userName;
- (void)saveUserPhone:(NSString *)phone;

@end
