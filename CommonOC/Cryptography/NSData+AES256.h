//
//  NSData+AES256.h
//  SVIP
//
//  Created by Hanton on 7/13/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end

//  NSString *key = @"my password";
//  NSString *secret = @"text to encrypt";
//  NSData *plain = [secret dataUsingEncoding:NSUTF8StringEncoding];
//  NSData *cipher = [plain AES256EncryptWithKey:key];
//  printf("%s\n", [[cipher description] UTF8String]);
//  plain = [cipher AES256DecryptWithKey:key];
//  printf("%s\n", [[plain description] UTF8String]);
//  printf("%s\n", [[[NSString alloc] initWithData:plain encoding:NSUTF8StringEncoding] UTF8String]);
