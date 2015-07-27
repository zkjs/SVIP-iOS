//
//  JSHCellModel.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHCellModel.h"

@implementation JSHCellModel
- (id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        _isSelected = [dic[@"isSelected"] boolValue];
        _itemTitle = dic[@"itemTitle"];
    }
    return self;
}
@end
