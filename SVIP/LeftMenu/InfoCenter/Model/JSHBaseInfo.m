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
//        _avatarStr = dic[@"user_avatar"];
//        if ([_avatarStr isKindOfClass:[NSNull class]]) {
//            _avatarStr = nil;
//        }
//        if (_avatarStr != nil) {
//            NSString *urlStr = [kBaseURL stringByAppendingPathComponent:_avatarStr];
//            NSURL *url = [NSURL URLWithString:urlStr];
//            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                    if (finished) {
//                        _avatarImage = image;
//                        [JSHStorage saveBaseInfoAvatar:image];
//                    }
//            }];
//        }
      
        _phone = dic[@"phone"];
        _username = dic[@"username"];
        _userid = dic[@"userid"];
        //用户头像  uploads/users/userid.jpg
        NSString *urlStr = [kBaseURL stringByAppendingPathComponent:[NSString stringWithFormat:@"uploads/users/%@.jpg",_userid]];
        NSURL *url = [NSURL URLWithString:urlStr];
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
          if (finished) {
            if (image) {
              _avatarImage = image;
              [JSHStorage saveBaseInfoAvatar:image];
            }
          }
        }];

        _openid = dic[@"openid"];
        if ([_openid isKindOfClass:[NSNull class]]) {
          _openid = nil;
        }
        _real_name = dic[@"real_name"];
        if ([_real_name isKindOfClass:[NSNull class]]) {
          _real_name = nil;
        }
        _email = dic[@"email"];
        if ([_email isKindOfClass:[NSNull class]]) {
          _email = nil;
        }
        _position = dic[@"remark"];
        if ([_position isKindOfClass:[NSNull class]]) {
            _position = nil;
        }
        _company = dic[@"preference"];
        if ([_company isKindOfClass:[NSNull class]]) {
            _company = nil;
        }
      _tagopen = [dic[@"tagopen"] intValue];
      _sex = dic[@"sex"]? @"男" : @"女";
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.openid forKey:@"openid"];
    [coder encodeObject:self.userid forKey:@"userid"];
    [coder encodeObject:self.avatarStr forKey:@"avatarStr"];
    [coder encodeObject:self.avatarImage forKey:@"avatarImage"];
    [coder encodeObject:self.phone forKey:@"phone"];
    [coder encodeObject:self.username forKey:@"username"];
    [coder encodeObject:self.real_name forKey:@"real_name"];
    [coder encodeObject:self.position forKey:@"position"];
    [coder encodeObject:self.company forKey:@"company"];
    [coder encodeObject:self.sex forKey:@"sex"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:[NSNumber numberWithInt:self.tagopen] forKey:@"tagopen"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.openid = [aDecoder decodeObjectForKey:@"openid"];
        self.userid = [aDecoder decodeObjectForKey:@"userid"];
        self.avatarStr = [aDecoder decodeObjectForKey:@"avatarStr"];
        self.avatarImage = [aDecoder decodeObjectForKey:@"avatarImage"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.real_name = [aDecoder decodeObjectForKey:@"real_name"];
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.company = [aDecoder decodeObjectForKey:@"company"];
        self.sex = [aDecoder decodeObjectForKey:@"sex"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.tagopen = [[aDecoder decodeObjectForKey:@"tagopen"] intValue];
    }
    return self;
}

@end