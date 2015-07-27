//
//  JSHCellModel.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSHCellModel : NSObject
@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) NSString *idStr;
@property (readonly, nonatomic) NSString *itemTitle;
- initWithDic:(NSDictionary *)dic;
@end
