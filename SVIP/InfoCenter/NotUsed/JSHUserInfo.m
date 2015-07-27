//
//  JSHInfo.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHUserInfo.h"

@implementation JSHUserInfo
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.baseInfo forKey:@"baseInfo"];
    [aCoder encodeObject:self.likeArray forKey:@"likeArray"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.baseInfo = [aDecoder decodeObjectForKey:@"baseInfo"];
        self.likeArray = [aDecoder decodeObjectForKey:@"likeArray"];
    }
    return self;
}

@end
