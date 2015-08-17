//
//  JSHBaseInfo.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface JSHBaseInfo : NSObject <NSCoding>
@property (strong, nonatomic) NSString *avatarStr;
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *phone;
//
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *position;
@property (strong, nonatomic) NSString *company;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *sex;//@"0"男     @"1"女
- (id)initWithDic:(NSDictionary *)dic;

//- (void)encodeWithCoder:(NSCoder *)coder;
//- (id)initWithCoder:(NSCoder *)aDecoder;
@end
