//
//  JSHSectionModel.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSHCellModel.h"
@interface JSHSectionModel : NSObject
@property (readonly, nonatomic) NSArray *itemsArray;
@property (readonly, nonatomic) NSString *sectionTitle;
- initWithDic:(NSDictionary *)dic;
@end
