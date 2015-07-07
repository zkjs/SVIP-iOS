//
//  JSHInfoEditShortHeaderView.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/29.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHInfoEditShortHeaderView.h"

@implementation JSHInfoEditShortHeaderView
+ (id)headerView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"JSHInfoEditShortHeaderView" owner:nil options:nil] lastObject];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
