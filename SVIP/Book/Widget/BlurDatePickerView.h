//
//  JSGCommentView.h
//  blur_comment
//
//  Created by dai.fengyi on 15/5/15.
//  Copyright (c) 2015年 childrenOurFuture. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BlurDatePickerViewDelegate <NSObject>
@optional
- (void)commentDidFinished:(NSDate *)date;
@end
typedef void(^SuccessBlock)(NSDate *date);
@interface BlurDatePickerView : UIImageView
//
+ (void)showInView:(UIView *)view success:(SuccessBlock)success;
+ (void)showInView:(UIView *)view delegate:(id <BlurDatePickerViewDelegate>)delegate;

//default is in [UIApplication sharedApplication].keyWindow
+ (void)showSuccess:(SuccessBlock)success;
+ (void)showDelegate:(id <BlurDatePickerViewDelegate>)delegate;

//for svip
+ (void)showInView:(UIView *)view startDate:(NSDate *)startDate success:(SuccessBlock)success;
@end
