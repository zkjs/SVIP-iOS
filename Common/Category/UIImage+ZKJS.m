//
//  UIImage+JSH.m
//  BeaconMall
//
//  Created by dai.fengyi on 15/5/8.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

#import "UIImage+ZKJS.h"

@implementation UIImage (ZKJS)
+(UIImage *)imageResizedWithName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    CGSize size = image.size;
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(size.width * 0.5, size.height * 0.5, size.width * 0.5, size.height * 0.5)];
}
@end
