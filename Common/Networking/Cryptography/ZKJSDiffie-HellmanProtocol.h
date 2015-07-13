//
//  ZKJSDiffie-HellmanProtocol.h
//  BeaconMall
//
//  Created by Hanton on 5/19/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKJSDiffie_HellmanProtocol : NSObject

+ (instancetype)sharedInstance;

- (int)test;
- (NSString *)base64StringFrom:(unsigned char *)characters withLength:(int)in_len;
- (NSString *)generateDHJSON;
- (NSString *)generateSessionKeyWithPublicKey:(NSString *)publicKey prime:(NSString *)prime generator:(NSString *)generator;
- (NSString *)generateSessionKeyWithPublicKey:(NSString *)public_key;

@end
