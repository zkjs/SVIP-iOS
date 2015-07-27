//
//  JSHInfoEditCell.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/29.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHInfoEditCell.h"

@implementation JSHInfoEditCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [[[NSBundle mainBundle] loadNibNamed:@"JSHInfoEditCell" owner:nil options:nil] lastObject];
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    if (selected == NO) {
//        _leftButton.selected = NO;
//        _rightButton.selected = NO;
//    }
    // Configure the view for the selected state
}
- (IBAction)buttonSelectAction:(UIButton *)sender {
    [self.delegate seletButton:(int)sender.tag section:_section];
}

@end
