//
//  JSHBaseInfo.m
//  HotelVIP
//
//  Created by dai.fengyi on 15/5/30.
//  Copyright (c) 2015年 ZKJS. All rights reserved.
//

#import "JSHBaseInfo.h"
#import "SDWebImageDownloader.h"
#import "Networkcfg.h"
#import "JSHStorage.h"
@implementation JSHBaseInfo
/*
 @property (strong, nonatomic) NSString *avatarStr;
 @property (strong, nonatomic) NSString *phone;
 //
 @property (strong, nonatomic) NSString *name;
 @property (strong, nonatomic) NSString *position;
 @property (strong, nonatomic) NSString *company;
 @property (strong, nonatomic) NSString *sex;//@"0"男     @"1"女
 */
- (id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        _avatarStr = dic[@"user_avatar"];
        if ([_avatarStr isKindOfClass:[NSNull class]]) {
            _avatarStr = nil;
        }
        if (_avatarStr != nil) {
            NSString *urlStr = [kBaseURL stringByAppendingPathComponent:_avatarStr];
            NSURL *url = [NSURL URLWithString:urlStr];
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    if (finished) {
                        _avatarImage = image;
                        [JSHStorage saveBaseInfoAvatar:image];
                    }
            }];
        }
        
        _phone = dic[@"phone"];
        _name = dic[@"username"];
        _position = dic[@"remark"];
        if ([_position isKindOfClass:[NSNull class]]) {
            _position = nil;
        }
        _company = dic[@"preference"];
        if ([_company isKindOfClass:[NSNull class]]) {
            _company = nil;
        }
      _sex = dic[@"sex"]? @"男" : @"女";
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.avatarStr forKey:@"avatarStr"];
    [coder encodeObject:self.avatarImage forKey:@"avatarImage"];
    [coder encodeObject:self.phone forKey:@"phone"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.position forKey:@"position"];
    [coder encodeObject:self.company forKey:@"company"];
    [coder encodeObject:self.sex forKey:@"sex"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.avatarStr = [aDecoder decodeObjectForKey:@"avatarStr"];
        self.avatarImage = [aDecoder decodeObjectForKey:@"avatarImage"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.company = [aDecoder decodeObjectForKey:@"company"];
        self.sex = [aDecoder decodeObjectForKey:@"sex"];
    }
    return self;
}

@end
