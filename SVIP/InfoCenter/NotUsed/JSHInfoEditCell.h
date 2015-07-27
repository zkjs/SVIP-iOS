//
//  JSHInfoEditCell.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/29.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InfoEditSelectionDelegate <NSObject>
- (void)seletButton:(int)itemIndex section:(int)itemSection;
@end
@interface JSHInfoEditCell : UITableViewCell
@property (weak, nonatomic) id<InfoEditSelectionDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (assign, nonatomic) int section;

@end
