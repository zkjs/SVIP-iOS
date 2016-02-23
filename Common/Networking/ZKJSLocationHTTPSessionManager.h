//
//  ZKJSLocationHTTPSessionManager.h
//  SVIP
//
//  Created by AlexBang on 16/2/23.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface ZKJSLocationHTTPSessionManager : AFHTTPSessionManager
#pragma mark - 单例
+ (instancetype)sharedInstance;
@end
