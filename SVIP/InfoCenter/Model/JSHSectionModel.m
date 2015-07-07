//
//  JSHSectionModel.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHSectionModel.h"
@implementation JSHSectionModel
- initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        _sectionTitle = dic[@"sectionTitle"];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (NSDictionary *aDic in dic[@"itemsArray"]) {
            JSHCellModel *cellModel = [[JSHCellModel alloc] initWithDic:aDic];
            [mutArr addObject:cellModel];
        }
        _itemsArray = [NSArray arrayWithArray:mutArr];
    }
    return self;
}
@end
