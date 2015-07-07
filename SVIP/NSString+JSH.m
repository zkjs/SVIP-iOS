//
//  NSString+JSH.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/6/12.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "NSString+JSH.h"

@implementation NSString (JSH)
+ (NSArray *)arrayWithSortedString:(NSString *)sortedString dividedByString:(NSString *)dividedString {
    NSMutableString *mutString = [NSMutableString stringWithString:sortedString];
    NSMutableArray *mutArray = [NSMutableArray array];
    while (1) {
        NSRange range = [mutString rangeOfString:dividedString];
        if (range.length != 0) {
            NSString *str = [mutString substringWithRange:NSMakeRange(0, range.location)];
            [mutArray addObject:str];
            [mutString replaceCharactersInRange:NSMakeRange(0, range.location + range.length) withString:@""];
        }else {
            [mutArray addObject:[NSString stringWithString:mutString]];
            break;
        }
    }
    return [NSArray arrayWithArray:mutArray];
}

+ (NSString *)stringWithArray:(NSArray *)array dividedByString:(NSString *)dividedString {
    NSMutableString *mutString = [NSMutableString string];
    for (NSString *string in array) {
        [mutString appendString:(mutString.length == 0 ? string : [NSString stringWithFormat:@"%@%@", dividedString, string])];
    }
    return [NSString stringWithString:mutString];
}
@end
