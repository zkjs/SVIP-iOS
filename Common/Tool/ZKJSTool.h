//
//  JSGtool.h
//  BeaconMall
//
//  Created by dai.fengyi on 4/28/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKJSTool : NSObject
#pragma mark - HUD
// 显示提示信息
+ (void)showMsg:(NSString *)message;

// 显示加载中...
+ (void)showLoading;

+ (void)showLoading:(NSString *)message;

// 隐藏所有指示器
+ (void)hideHUD;

#pragma mark - 
//检测手机号码是否合法
+ (BOOL)validateMobile:(NSString *)mobileNum;
//检测邮箱格式
+ (BOOL)validateEmail:(NSString *)email;
#pragma mark - 动画


@end
