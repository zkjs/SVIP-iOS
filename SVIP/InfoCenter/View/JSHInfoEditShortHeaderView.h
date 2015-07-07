//
//  JSHInfoEditShortHeaderView.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/29.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHBaseHeaderView.h"
@interface JSHInfoEditShortHeaderView : JSHBaseHeaderView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;


+ (id)headerView;
@end
