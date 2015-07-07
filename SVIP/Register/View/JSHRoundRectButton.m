//
//  JSGButton.m
//  BeaconMall
//
//  Created by dai.fengyi on 15/4/24.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

#import "JSHRoundRectButton.h"

@implementation JSHRoundRectButton
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUI];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI
{
    self.clipsToBounds = YES;

}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    self.layer.cornerRadius = self.bounds.size.height * 0.5;
}


@end
