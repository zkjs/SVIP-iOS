//
//  JSGCommentView.m
//  blur_comment
//
//  Created by dai.fengyi on 15/5/15.
//  Copyright (c) 2015年 childrenOurFuture. All rights reserved.
//

#import "BlurDatePickerView.h"
#import "UIImageEffects.h"
#define ANIMATE_DURATION    0.3f
#define kMarginWH           10
#define kButtonWidth        70
#define kButtonHeight       30
#define kTextFont           [UIFont systemFontOfSize:14]
#define kTextViewHeight     216
#define kSheetViewHeight    (kMarginWH * 3 + kButtonHeight + kTextViewHeight)
@interface BlurDatePickerView ()
@property (strong, nonatomic) SuccessBlock success;
@property (weak, nonatomic) id<BlurDatePickerViewDelegate> delegate;
@property (strong, nonatomic) UIView *sheetView;
//@property (strong, nonatomic) UITextView *commentTextView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@end
@implementation BlurDatePickerView
+ (id)showInView:(UIView *)view success:(SuccessBlock)success delegate:(id <BlurDatePickerViewDelegate>)delegate
{
    BlurDatePickerView *commentView = [[BlurDatePickerView alloc] initWithFrame:view.bounds];
    if (commentView) {
        //增加EventResponsor
//        [commentView addEventResponsors];
        //block or delegate
        commentView.success = success;
        commentView.delegate = delegate;
        commentView.userInteractionEnabled = YES;
        //截图并虚化
        commentView.image = [UIImageEffects imageByApplyingCustomEffectToImage:[commentView snapShot:view] radius:2];
        [view addSubview:commentView];
        [view addSubview:commentView.sheetView];
//        [commentView.commentTextView becomeFirstResponder];
        [UIView animateWithDuration:ANIMATE_DURATION animations:^{
          commentView.alpha = 1;
          commentView.sheetView.frame = CGRectMake(0, commentView.superview.bounds.size.height - commentView.sheetView.bounds.size.height, commentView.sheetView.bounds.size.width, kSheetViewHeight);
        } completion:nil];
    }
  return commentView;
}
#pragma mark - 外部调用
+ (void)showSuccess:(SuccessBlock)success
{
    [BlurDatePickerView showInView:[UIApplication sharedApplication].keyWindow success:success delegate:nil];
}

+ (void)showDelegate:(id<BlurDatePickerViewDelegate>)delegate
{
    [BlurDatePickerView showInView:[UIApplication sharedApplication].keyWindow success:nil delegate:delegate];
}

+ (void)showInView:(UIView *)view success:(SuccessBlock)success
{
    [BlurDatePickerView showInView:view success:success delegate:nil];
}

+ (void)showInView:(UIView *)view delegate:(id<BlurDatePickerViewDelegate>)delegate
{
    [BlurDatePickerView showInView:view success:nil delegate:delegate];
}

//for Svip
+ (void)showInView:(UIView *)view startDate:(NSDate *)startDate success:(SuccessBlock)success
{
  BlurDatePickerView *commentView = [BlurDatePickerView showInView:view success:success delegate:nil];
  commentView.datePicker.minimumDate = startDate;
}
#pragma mark - 内部调用
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    self.alpha = 0;
    
    CGRect rect = self.bounds;
    _sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height, rect.size.width, kSheetViewHeight)];
    _sheetView.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(kMarginWH, kMarginWH, kButtonWidth, kButtonHeight);
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = kTextFont;
    [cancelButton addTarget:self action:@selector(cancelComment:) forControlEvents:UIControlEventTouchUpInside];
    [_sheetView addSubview:cancelButton];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.frame = CGRectMake(_sheetView.bounds.size.width - kButtonWidth - kMarginWH, kMarginWH, kButtonWidth, kButtonHeight);
    commentButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [commentButton setTitle:@"确定" forState:UIControlStateNormal];
    [commentButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    commentButton.titleLabel.font = kTextFont;
    [commentButton addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
    [_sheetView addSubview:commentButton];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"选择日期";
    label.frame = CGRectMake((_sheetView.bounds.size.width - kButtonWidth) / 2, kMarginWH, kButtonWidth, kButtonHeight);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = kTextFont;
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [_sheetView addSubview:label];
    
//    _commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(kMarginWH, _sheetView.bounds.size.height - kMarginWH - kTextViewHeight, rect.size.width - kMarginWH * 2, kTextViewHeight)];
//    _commentTextView.text = nil;
//    [_sheetView addSubview:_commentTextView];
//    _datePicker = [[UIDatePicker alloc] init];
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(kMarginWH, _sheetView.bounds.size.height - kMarginWH - kTextViewHeight, rect.size.width - kMarginWH * 2, kTextViewHeight)];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [_sheetView addSubview:_datePicker];
}

- (UIImage *)snapShot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//- (void)addEventResponsors
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//}

#pragma mark - Botton Action
- (void)cancelComment:(id)sender {
    [_sheetView endEditing:YES];
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
      self.alpha = 0;
      _sheetView.frame = CGRectMake(0, self.superview.bounds.size.height, _sheetView.bounds.size.width, kSheetViewHeight);
    } completion:^(BOOL finished){
      [self dismissCommentView];
    }];
}
- (void)comment:(id)sender {
    //发送请求
    if (_success) {
        _success(_datePicker.date);
    }
    if ([_delegate respondsToSelector:@selector(commentDidFinished:)]) {
        [_delegate commentDidFinished:_datePicker.date];
    }
    [_sheetView endEditing:YES];
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
      self.alpha = 0;
      _sheetView.frame = CGRectMake(0, self.superview.bounds.size.height, _sheetView.bounds.size.width, kSheetViewHeight);
    } completion:^(BOOL finished){
      [self dismissCommentView];
    }];
}

- (void)dismissCommentView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeFromSuperview];
    [_sheetView removeFromSuperview];
}
//#pragma mark - Keyboard Notification Action
//- (void)keyboardWillShow:(NSNotification *)aNotification
//{
//    NSLog(@"%@", aNotification);
//    CGFloat keyboardHeight = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//    NSTimeInterval animationDuration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    [UIView animateWithDuration:animationDuration animations:^{
//        self.alpha = 1;
//        _sheetView.frame = CGRectMake(0, self.superview.bounds.size.height - _sheetView.bounds.size.height - keyboardHeight, _sheetView.bounds.size.width, kSheetViewHeight);
//    } completion:nil];
//}
//
//- (void)keyboardWillHide:(NSNotification *)aNotification
//{
//    NSDictionary *userInfo = [aNotification userInfo];
//    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    [UIView animateWithDuration:animationDuration animations:^{
//        self.alpha = 0;
//        _sheetView.frame = CGRectMake(0, self.superview.bounds.size.height, _sheetView.bounds.size.width, kSheetViewHeight);
//    } completion:^(BOOL finished){
//        [self dismissCommentView];
//    }];
//}
@end