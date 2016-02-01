//
//  BrowserImageView.m
//  SVIP
//
//  Created by AlexBang on 15/12/30.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

#import "BrowserImageView.h"

@implementation BrowserImageView
{
  id _target;
  SEL _action;
}

-(void)addTarget:(id)obj action:(SEL)action{
  self.userInteractionEnabled = YES ;
  if (obj && action) {
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:obj action:action];
    [self addGestureRecognizer:tap];
  }
}



@end
