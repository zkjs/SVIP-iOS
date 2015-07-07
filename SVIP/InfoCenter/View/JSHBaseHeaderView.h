//
//  JSHBaseHeaderView.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/29.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSHRoundRectButton.h"
@protocol EditHeaderDelegate<NSObject>
- (void)headerClicked:(id)sender;
@end
@interface JSHBaseHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet JSHRoundRectButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) id<EditHeaderDelegate> delegate;
+ (id)headerView;
@end
