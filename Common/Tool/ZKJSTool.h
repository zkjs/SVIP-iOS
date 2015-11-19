//
//  JSGtool.h
//  BeaconMall
//
//  Created by dai.fengyi on 4/28/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKJSTool : NSObject

#pragma mark - 显示提示信息
+ (void)showMsg:(NSString *)message;

#pragma mark - 检测手机号码是否合法
+ (BOOL)validateMobile:(NSString *)mobileNum;

#pragma mark - 检测邮箱格式
+ (BOOL)validateEmail:(NSString *)email;

@end
