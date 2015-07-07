//
//  JSHBaseHeaderView.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/29.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHBaseHeaderView.h"

@implementation JSHBaseHeaderView
- (void)awakeFromNib
{
    [super awakeFromNib];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickInView:)];
    [_bgImageView addGestureRecognizer:tap];
}
+ (id)headerView
{
    return [[UIView alloc] init];
}

- (void)clickInView:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(headerClicked:)]) {
        [self.delegate headerClicked:sender];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
