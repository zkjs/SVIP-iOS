//
//  JSHAnimationVC.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/6/8.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHAnimationVC.h"
#import "JSHRegisterAnimationView.h"
#import "JSHAccountManager.h"
#import "JSHHotelRegisterVC.h"
#import "SVIP-swift.h"
#define kDuration       2.0f
#define kDelay          0.7f
@implementation JSHAnimationVC
{
    __weak IBOutlet UIImageView *_logo;
    __weak IBOutlet UILabel *_welcomeWords;
    __weak IBOutlet UIImageView *_plane;
}

- (instancetype)init
{
    self = [super initWithNibName:@"RegisterAnimationView" bundle:nil];
    if (self) {
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [JSHRegisterAnimationView showInView:self.view];
    [self startAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

//+(void)showInView:(UIView *)view
//{
//    JSHRegisterAnimationView *animationView = [[[NSBundle mainBundle] loadNibNamed:@"RegisterAnimationView" owner:nil options:nil] lastObject];
//    //    animationView.frame = [UIScreen mainScreen].bounds;
//    animationView.frame = view.bounds;
//    //    [[UIApplication sharedApplication].keyWindow addSubview:animationView];
//    [view addSubview:animationView];
//    [animationView startAnimation];
//}

- (void)startAnimation
{
    [UIView animateWithDuration:kDuration animations:^{
//        _plane.transform = CGAffineTransformMakeScale(1.2, 1.2);
        _plane.bounds = CGRectMake(0, 0, 958 / 2, 1704 / 2);
//        _welcomeWords.frame = CGRectMake(_welcomeWords.frame.origin.x, CGRectGetMaxY(_logo.frame) + 10, _welcomeWords.bounds.size.width, _welcomeWords.bounds.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
//            [self removeFromSuperview];
            if ([JSHAccountManager sharedJSHAccountManager].userid) {
                //已注册 jump
                 UINavigationController *navigationController = [UINavigationController new];
                 navigationController.navigationBarHidden = YES;
                [navigationController setViewControllers:@[[MainVC new]] animated:NO];
                [[UIApplication sharedApplication].windows[0] setRootViewController:navigationController];
              
            }else {
                //未注册 jump
                [self presentViewController:[JSHHotelRegisterVC new] animated:YES completion:^{
//
                }];
            }
          
        }
    }];
    
    [UIView animateWithDuration:kDuration - kDelay delay:kDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
        _logo.alpha = 1;
        _welcomeWords.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
//    [UIView animateWithDuration:kDelay animations:^{
//        _welcomeWords.alpha = 1;
//    }];
}

@end
