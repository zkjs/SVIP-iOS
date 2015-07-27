//
//  JSHInfo.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JSHBaseInfo;
@interface JSHUserInfo : NSObject <NSCoding>
@property (strong, nonatomic) JSHBaseInfo *baseInfo;//基本信息
@property (strong, nonatomic) NSArray *likeArray;//标签
@end
