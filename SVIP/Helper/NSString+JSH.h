//
//  NSString+JSH.h
//  HotelVIP
//
//  Created by dai.fengyi on 15/6/12.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSH)
+ (NSArray *)arrayWithSortedString:(NSString *)sortedString dividedByString:(NSString *)dividedString;
+ (NSString *)stringWithArray:(NSArray *)array dividedByString:(NSString *)dividedString;
@end
