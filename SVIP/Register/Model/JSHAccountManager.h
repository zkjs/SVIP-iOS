//
//  JSHAccount.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/6/6.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
@interface JSHAccountManager : NSObject
single_interface(JSHAccountManager)
@property (readonly, nonatomic) NSString *userid;
@property (readonly, nonatomic) NSString *token;
- (void)saveAccountWithDic:(NSDictionary *)dic;
@end
