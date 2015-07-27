//
//  JSHInfoEditLabelModel.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/6/5.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface JSHInfoEditLabelLevel1Model : NSObject
@property (copy, nonatomic) NSString *idStr;
@property (copy, nonatomic) NSString *fid;
@property (copy, nonatomic) NSString *tag;
@property (copy, nonatomic) NSString *choes;
@property (copy, nonatomic) NSArray *children;
@property (assign, nonatomic) BOOL isSelected;

@end


@interface JSHInfoEditLabelLevel2Model : NSObject

@end


@interface JSHInfoEditLabelLevel3Model : NSObject

@end