//
//  JSGRoundRectTextField.h
//  BeaconMall
//
//  Created by dai.fengyi on 15/4/24.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTextFieldINTERVALWIDTH          5
#define kTextFieldWIDTHMARGIN            2
#define kTextFieldRightButtonW           30
#define kTextFieldRightButtonH           30

#define kTextFieldDeleteButtonWH         19
typedef void(^RightButtonBlock)();
@interface JSHTextField : UITextField
{
    UIButton *_rightButton;
    RightButtonBlock _rightButtonBlock;
}
@property (strong, nonatomic) UIButton *rightButton;
- (void)setupUI;
- (void)addLeftImageView:(NSString *)imageName;
- (void)addRightButtonWithDefaultImage:(NSString *)defaultImage highlightImage:(NSString *)highlightImage Action:(RightButtonBlock)rightButtonBlock;
@end
