//
//  JSHInfoEditHeader.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSHInfoEditHeaderFrame.h"
#import "JSHRoundRectButton.h"
@interface JSHInfoEditHeader : UIView <UITextFieldDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UIViewController *viewController;

@property (strong, nonatomic) JSHInfoEditHeaderFrame *headerFrame;

@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) JSHRoundRectButton *avatarButton;
@property (strong, nonatomic) UILabel *phoneLabel;
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *positionField;
@property (strong, nonatomic) UITextField *companyField;
@property (strong, nonatomic) UIButton *maleButton;
@property (strong, nonatomic) UIButton *femaleButton;

- (void)changeFrame;
@end
