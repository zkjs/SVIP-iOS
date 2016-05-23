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
+ (void)showMsg:(NSString *)message;

#pragma mark - 检测手机号码是否合法
+ (BOOL)validateMobile:(NSString *)mobileNum;

#pragma mark - 检测邮箱格式
+ (BOOL)validateEmail:(NSString *)email;

#pragma mark - JSON String <=> Dictionary
+ (NSDictionary *)convertJSONStringToDictionary:(NSString *)jsonString;
+ (NSString *)convertJSONStringFromDictionary:(NSDictionary *)dictionary;

#pragma mark - 判断日期是否过期
+(int)compareOneDay:(NSString *)oneDay withAnotherDay:(NSString *)anotherDay;

#pragma mark - 获取手机分辨率
+ (int)getResolution;

@end
