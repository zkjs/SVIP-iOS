//
//  JSHInfoEditHeaderFrame.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//
//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSHBaseInfo.h"
@interface JSHInfoEditHeaderFrame : NSObject
@property (assign, nonatomic, getter = isEdit) BOOL Edit;
@property (strong, nonatomic) JSHBaseInfo *baseInfo;

@property (readonly, nonatomic) CGRect viewFrame;
@property (readonly, nonatomic) CGRect bgImageFrame;
@property (readonly, nonatomic) CGRect avatarButtonFrame;
@property (readonly, nonatomic) CGRect phoneLabelFrame;
//
@property (readonly, nonatomic) CGRect nameFieldFrame;
@property (readonly, nonatomic) CGRect positionFieldFrame;
@property (readonly, nonatomic) CGRect companyFieldFrame;
//
@property (readonly, nonatomic) CGRect maleButtonFrame;
@property (readonly, nonatomic) CGRect femaleButtonFrame;
@end
