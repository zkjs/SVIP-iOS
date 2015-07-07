//
//  JSHInfoEditHeaderView.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/29.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHInfoEditHeaderView.h"

@implementation JSHInfoEditHeaderView
+ (id)headerView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"JSHInfoEditHeaderView" owner:nil options:nil] lastObject];
}

@end
