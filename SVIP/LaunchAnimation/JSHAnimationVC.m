//
//  JSHAnimationVC.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/6/8.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHAnimationVC.h"
#import "SVIP-swift.h"
#define kDuration       2.0f
#define kDelay          0.7f
@implementation JSHAnimationVC {
  __weak IBOutlet UIImageView *_logo;
  __weak IBOutlet UILabel *_welcomeWords;
  __weak IBOutlet UIImageView *_plane;
}

- (instancetype)init {
  self = [super initWithNibName:@"RegisterAnimationView" bundle:nil];
  if (self) {
    
  }
  return self;
}
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self startAnimation];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _welcomeWords.text = NSLocalizedString(@"SLOGAN", nil);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)startAnimation {
  [UIView animateWithDuration:kDuration animations:^{
    _plane.bounds = CGRectMake(0, 0, 958 / 2, 1704 / 2);
  } completion:^(BOOL finished) {
    if (finished) {
      [[LoginManager sharedInstance] afterAnimation];
    }
  }];
  
  [UIView animateWithDuration:kDuration - kDelay delay:kDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
    _logo.alpha = 1;
    _welcomeWords.alpha = 1;
  } completion:^(BOOL finished) {
    
  }];
}

@end
