/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "UIViewController+HUD.h"

#import "MBProgressHUD.h"
#import <objc/runtime.h>

static const void *HttpRequestHUDKey = &HttpRequestHUDKey;

@implementation UIViewController (HUD)

- (MBProgressHUD *)HUD {
    return objc_getAssociatedObject(self, HttpRequestHUDKey);
}

- (void)setHUD:(MBProgressHUD *)HUD {
    objc_setAssociatedObject(self, HttpRequestHUDKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showHudInView:(UIView *)view hint:(NSString *)hint {
  MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
  HUD.labelText = hint;
  HUD.labelFont = [UIFont systemFontOfSize:12.0];
  [view addSubview:HUD];
  [HUD show:YES];
  [self setHUD:HUD];
}

- (void)showHint:(NSString *)hint yOffset:(float)yOffset {
  //显示提示信息
  UIView *view = [[UIApplication sharedApplication].delegate window];
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
  hud.userInteractionEnabled = NO;
  // Configure for text only and offset down
  hud.mode = MBProgressHUDModeText;
  hud.labelText = hint;
  hud.labelFont = [UIFont systemFontOfSize:12.0];
  hud.margin = 10.f;
  hud.yOffset = 180;
  hud.yOffset += yOffset;
  hud.removeFromSuperViewOnHide = YES;
  [hud hide:YES afterDelay:2];
}

- (void)hideHud {
  [[self HUD] hide:YES];
}

- (void)showHUDInView:(UIView *)view withLoading:(NSString *)hint {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.labelText = hint;
    HUD.labelFont = [UIFont systemFontOfSize:12.0];
    [view addSubview:HUD];
//    HUD.yOffset = view.bounds.size.height - ([UIScreen mainScreen].bounds.size.height)/2.0 + HUD.frame.size.height/2.0;
    [HUD show:YES];
    [self setHUD:HUD];
}

- (void)showHUDInTableView:(UITableView *)tableView withLoading:(NSString *)hint {
  MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:tableView];
  HUD.labelText = hint;
  HUD.labelFont = [UIFont systemFontOfSize:12.0];
  [tableView addSubview:HUD];
  HUD.yOffset = tableView.contentOffset.y;
  [HUD show:YES];
  [self setHUD:HUD];
}

- (void)showHint:(NSString *)hint
{
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    HUD.userInteractionEnabled = NO;
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = hint;
    HUD.labelFont = [UIFont systemFontOfSize:14.0];
    HUD.margin = 10.f;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:2];
}

- (void)showHint:(NSString *)hint withFontSize:(CGFloat) fontSize
{
  //显示提示信息
  UIView *view = [[UIApplication sharedApplication].delegate window];
  MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
  HUD.userInteractionEnabled = NO;
  HUD.mode = MBProgressHUDModeText;
  HUD.labelText = hint;
  HUD.labelFont = [UIFont systemFontOfSize:fontSize];
  HUD.margin = 10.f;
  HUD.removeFromSuperViewOnHide = YES;
  [HUD hide:YES afterDelay:2];
}

- (void)showErrorHint:(NSError *)error
{
  //显示提示信息
  NSString *msg;
  if(error.userInfo[@"resDesc"]) {
    msg = error.userInfo[@"resDesc"];
  } else {
    msg = [NSString stringWithFormat:@"数据请求错误:%ld", error.code];
  }
  [self showHint:msg];
}

- (void)showErrorHint:(NSError *)error withFontSize:(CGFloat) fontSize
{
  //显示提示信息
  NSString *msg;
  if(error.userInfo[@"resDesc"]) {
    msg = error.userInfo[@"resDesc"];
  } else {
    msg = [NSString stringWithFormat:@"数据请求错误:%ld", error.code];
  }
  [self showHint:msg withFontSize:fontSize];
}



- (void)hideHUD {
    [[self HUD] hide:YES];
}

@end
