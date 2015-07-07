//
//  JSHRegisterAnimationView.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/28.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHRegisterAnimationView.h"
#define kDuration       2.0f
#define kDelay          0.7f

@implementation JSHRegisterAnimationView
{
    __weak IBOutlet UIImageView *_logo;
    __weak IBOutlet UILabel *_welcomeWords;
    __weak IBOutlet UIImageView *_plane;
}

//+(void)showAnimationView
+(void)showInView:(UIView *)view
{
    JSHRegisterAnimationView *animationView = [[[NSBundle mainBundle] loadNibNamed:@"RegisterAnimationView" owner:nil options:nil] lastObject];
//    animationView.frame = [UIScreen mainScreen].bounds;
    animationView.frame = view.bounds;
//    [[UIApplication sharedApplication].keyWindow addSubview:animationView];
    [view addSubview:animationView];
    [animationView startAnimation];
}

- (void)startAnimation
{
    [UIView animateWithDuration:kDuration animations:^{
        _plane.transform = CGAffineTransformMakeScale(1.5, 1.5);
        _welcomeWords.frame = CGRectMake(_welcomeWords.frame.origin.x, CGRectGetMaxY(_logo.frame) + 10, _welcomeWords.bounds.size.width, _welcomeWords.bounds.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
    
    [UIView animateWithDuration:kDuration - kDelay delay:kDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
        _logo.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:kDelay animations:^{
        _welcomeWords.alpha = 1;
    }];
}
@end