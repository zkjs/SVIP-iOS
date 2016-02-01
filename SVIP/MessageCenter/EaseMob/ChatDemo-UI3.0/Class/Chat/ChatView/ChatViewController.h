//
//  ChatViewController.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EaseUI.h"

@class OrderDetailModel;

#define KNOTIFICATIONNAME_DELETEALLMESSAGE @"RemoveAllMessages"

@interface ChatViewController : EaseMessageViewController

@property(strong,nonatomic)NSString * chatter;
@property (strong, nonatomic) OrderDetailModel *order;
@property (strong, nonatomic) NSString *firstMessage;

@end
