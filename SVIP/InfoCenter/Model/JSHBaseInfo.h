//
//  JSHBaseInfo.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//
/*
 补充说明:
 API中 username 对应本地 username 意思是昵称
       real_name  对应本地 real_name
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface JSHBaseInfo : NSObject <NSCoding>
@property (strong, nonatomic) NSString *avatarStr;
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *phone;
//
@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *real_name;
@property (strong, nonatomic) NSString *position;
@property (strong, nonatomic) NSString *company;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *sex;//@"0"男     @"1"女
- (id)initWithDic:(NSDictionary *)dic;

//- (void)encodeWithCoder:(NSCoder *)coder;
//- (id)initWithCoder:(NSCoder *)aDecoder;
@end
